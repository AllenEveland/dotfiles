#!/usr/bin/env bash

MODE="${1:-normal}"

REGION=$(slurp) || exit 1

case "$MODE" in
    normal)
        SAVE_DIR="$HOME/Pictures/Screenshots"
        mkdir -p "$SAVE_DIR"
        grim -g "$REGION" "$SAVE_DIR/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"
        ;;
    clipboard)
        command -v wl-copy &>/dev/null || { echo "error: wl-copy not found" >&2; exit 1; }
        grim -g "$REGION" - | wl-copy --type image/png
        ;;
esac

