#!/bin/bash

. $(dirname $(realpath "$0"))/lib.sh

wait-for-konsole

set -e

file="$1"
[ -z "$file" ] && exit 1

for w in $(kdbus /Application windowList); do
    if [ $(kdbus /Windows/$w name) != "$LOG_WINDOW_NAME" ]; then
        window=$w
        break;
    fi
done

if [ -z "$window" ]; then
    window=$(kdbus /Application openNewWindow)
else
    kdbus /Application raiseWindow $window
fi

found=false
for s in $(kdbus /Windows/$window sessionList); do
    for pid in $(pgrep -P $(kdbus /Sessions/$s processId)); do
        exe="$(readlink /proc/$pid/exe || true)"
        if [[ "$exe" == *"/tig" ]]; then
            [ "$(cut -d '' -f2 /proc/$pid/cmdline)" == "$file" ] && found=true
        fi
    done
    if $found; then
        session=$s
        break
    fi
done

if [ -z "$session" ]; then
    session=$(kdbus /Windows/$window newSession)
    dir="$(dirname "$file")"
    file="$(basename "$file")"
    qdbus org.kde.konsole /Sessions/$session runCommand "cd \"$dir\" && tig \"$file\""
fi

kdbus /Windows/$window setCurrentSession $session
