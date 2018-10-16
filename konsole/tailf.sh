#!/bin/bash

. $(dirname $(realpath "$0"))/lib.sh

wait-for-konsole

set -e

file="$1"
[ -z "$file" ] && exit 1

w=$(kdbus /Application windowList)
# w=$(kdbus /Application getWindowByName "$LOG_WINDOW_NAME")
if [ -z "$w" ]; then
    w=$(kdbus /Application openNewWindow)
    kdbus /Windows/$w setName "$LOG_WINDOW_NAME"
    newsession=$(kdbus /Windows/$w sessionList)
else
    sessions="$(kdbus /Windows/$w sessionList)"
    for s in $sessions; do
        found_tailf=false
        found_nl=false
        for pid in $(pgrep -P $(kdbus /Sessions/$s processId)); do
            exe="$(readlink /proc/$pid/exe || true)"
            if [[ "$exe" == *"/tailf" ]]; then
                [ "$(cut -d '' -f2 /proc/$pid/cmdline)" == "$file" ] && found_tailf=true
            elif [[ "$exe" == *"/nl" ]]; then
                found_nl=true
            fi
        done
        if $found_tailf && $found_nl; then
            session=$s
            break
        fi
    done
fi

if [ -z "$session" ]; then
    newsession=${newsession:-$(kdbus /Windows/$w newSession)}
    kdbus /Sessions/$newsession runCommand "tailf \"$file\" | nl"
    kdbus /Sessions/$newsession setTitle 1 "$file"
else
    kdbus /Windows/$w setCurrentSession $session
fi

kdbus /Application raiseWindow $w

