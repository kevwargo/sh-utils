#!/bin/bash

. $(dirname $(realpath "$0"))/lib.sh

set -e

while [ $# -gt 0 ]; do
    case "$1" in
        -f | --first )
            first=yes
            ;;
        * )
            dir="$(realpath "$1" 2>/dev/null)"
            ;;
    esac
    shift
done

[ -z "$dir" ] && exit 1

konsole_wait

for window in $(kdbus | grep '/Windows/[0-9]\+'); do
    winidx=${window#/Windows/}
    for s in $(kdbus $window sessionList); do
        pid=$(kdbus /Sessions/$s processId)
        cwd=$(readlink -f /proc/$pid/cwd)
        if [ -z "$(pgrep -P $pid)" ]; then
            if [ "$cwd" == "$dir" ] || [ -n "$first" ]; then
                session=$s
                break 2
            fi
        fi
    done
done

if [ -z "$session" ]; then
    session=$(kdbus $window newSession)
fi

qdbus org.kde.konsole /Sessions/$session runCommand "cd \"$dir\""
kdbus $window setCurrentSession $session
wmctrl -i -R $(kdbus /konsole/MainWindow_$winidx winId)
