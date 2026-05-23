#! /usr/bin/env bash

theme="$HOME/.allenconf/themes/rofitheme.rasi"

killall rofi;
chosen=$(printf \
"  Lock\n󰍃  Logout\n󰤄  Suspend\n󰜉  Reboot\n  Shutdown" \
| rofi -dmenu -theme ${theme} -i -p "Power")

case "$chosen" in
    *Lock)
        hyprlock
        ;;
    *Logout)
        hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'
        ;;
    *Suspend)
        systemctl suspend
        ;;
    *Reboot)
        systemctl reboot
        ;;
    *Shutdown)
        systemctl poweroff
        ;;
esac

