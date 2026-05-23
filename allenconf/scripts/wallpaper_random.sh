#!/usr/bin/env bash

wallpapers_dir="$HOME/.allenconf/wallpapers/"

random_wallpaper=$(find "$wallpapers_dir" -maxdepth 1 -type f | shuf -n 1)

awww img "$random_wallpaper" --transition-type any --transition-duration 2

~/.allenconf/scripts/wallpaper_effect.sh
