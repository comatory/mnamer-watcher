#!/usr/bin/env bash
set -euo pipefail

MNAMER_CONFIG="${MNAMER_CONFIG:-/mnt/.config/.mnamer-v2.json}"
EXCLUDE_PATTERN="${EXCLUDE_PATTERN:-/incomplete/}"

INOTIFY_ARGS=(-m -r -e close_write -e moved_to --format '%w%f')
if [[ -n "$EXCLUDE_PATTERN" ]]; then
  INOTIFY_ARGS+=(--exclude "$EXCLUDE_PATTERN")
fi

echo "Watching /mnt/watch for new files..."
inotifywait "${INOTIFY_ARGS[@]}" "/mnt/watch" | while read -r FILE; do
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Detected: $FILE"
  python -m mnamer --batch --config-path="$MNAMER_CONFIG" "$FILE"
done
