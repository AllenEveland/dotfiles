#!/usr/bin/env bash

ACTION="$1"

WORKSPACE=$(hyprctl activeworkspace | awk 'NR==1 {print $3}')

if [[ "$ACTION" == "next" ]]; then
    WORKSPACE=$(( WORKSPACE + 1 ))
elif [[ "$ACTION" == "prev" ]]; then
    [[ "$WORKSPACE" -le 1 ]] && exit 0
    WORKSPACE=$(( WORKSPACE - 1 ))
fi

hyprctl dispatch "hl.dsp.focus({ workspace = ${WORKSPACE} })"

