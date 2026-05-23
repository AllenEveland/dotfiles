#! /usr/bin/env bash

theme="$HOME/.allenconf/themes/rofitheme.rasi"

killall rofi;
rofi -show drun -theme ${theme}

