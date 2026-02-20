#!/usr/bin/env bash
set -euo pipefail

MNAMER_CONFIG="${MNAMER_CONFIG:-/mnt/.config/.mnamer-v2.json}"
EXCLUDE_PATTERN="${EXCLUDE_PATTERN:-/incomplete/}"

INOTIFY_ARGS=(-m -e close_write -e moved_to --format '%e %w%f')
if [[ -n "$EXCLUDE_PATTERN" ]]; then
  INOTIFY_ARGS+=(--exclude "$EXCLUDE_PATTERN")
fi

process_file() {
  local FILE="$1"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Detected: $FILE"
  python -m mnamer --batch --config-path="$MNAMER_CONFIG" "$FILE"
}

echo "Watching /mnt/watch for new files..."
inotifywait "${INOTIFY_ARGS[@]}" "/mnt/watch" | while read -r EVENT FILE; do
  if [[ -d "$FILE" ]]; then
    find "$FILE" -type f | while read -r SUBFILE; do
      process_file "$SUBFILE"
    done
  else
    process_file "$FILE"
  fi
done
