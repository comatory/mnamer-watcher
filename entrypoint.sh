#!/usr/bin/env bash
set -euo pipefail

MNAMER_CONFIG="${MNAMER_CONFIG:-/mnt/.config/.mnamer-v2.json}"
EXCLUDE_PATTERN="${EXCLUDE_PATTERN:-/incomplete/}"

process_file() {
  local FILE="$1"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Detected: $FILE"
  python -m mnamer --batch --config-path="$MNAMER_CONFIG" "$FILE"
}

process_dir() {
  local DIR="$1"
  [[ -d "$DIR" ]] || return
  find "$DIR" -type f | while read -r FILE; do
    process_file "$FILE"
  done
}

wait_and_process_dir() {
  local DIR="$1"
  # loop until no events for 5s (all files have arrived)
  while inotifywait -r -q -e close_write -e moved_to --timeout 5 "$DIR" 2>/dev/null; do
    :
  done
  process_dir "$DIR"
}

INOTIFY_ARGS=(-m -e close_write -e moved_to -e create --format '%e %w%f')
if [[ -n "$EXCLUDE_PATTERN" ]]; then
  INOTIFY_ARGS+=(--exclude "$EXCLUDE_PATTERN")
fi

echo "Watching /mnt/watch for new files..."
inotifywait "${INOTIFY_ARGS[@]}" "/mnt/watch" | while read -r EVENT FILE; do
  if [[ -n "$EXCLUDE_PATTERN" ]] && [[ "$FILE" =~ $EXCLUDE_PATTERN ]]; then
    continue
  fi

  if [[ "$EVENT" == *ISDIR* ]]; then
    if [[ "$EVENT" == MOVED_TO* ]]; then
      # directory moved atomically — files already there
      process_dir "$FILE"
    else
      # directory just created — wait for files to arrive, then scan
      wait_and_process_dir "$FILE" &
    fi
  elif [[ -f "$FILE" ]]; then
    process_file "$FILE"
  fi
done
