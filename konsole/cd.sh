#!/bin/bash

. $(dirname $(realpath "$0"))/lib.sh

wait-for-konsole

set -e

dir="$(realpath "$1" 2>/dev/null)"
[ -z "$dir" ] && exit 1

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

for s in $(kdbus /Windows/$window sessionList); do
    pid="$(kdbus /Sessions/$s processId)"
    d="$(readlink /proc/$pid/cwd)"
    if [ "$d" == "$dir" ] && [ -z "$(pgrep -P $pid)" ]; then
        session=$s
        break
    fi
done

if [ -z "$session" ]; then
    session=$(kdbus /Windows/$window newSession)
    qdbus org.kde.konsole /Sessions/$session runCommand "cd \"$dir\""
fi

kdbus /Windows/$window setCurrentSession $session
