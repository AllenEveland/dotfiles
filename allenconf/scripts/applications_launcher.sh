#! /usr/bin/env bash

theme="$HOME/.config/rofi/theme.rasi"

killall rofi;
rofi -show drun -theme ${theme}

