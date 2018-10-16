#!/bin/bash

dir="${1:-/mnt/other/screens}"
window="${2:-$(wmiface activeWindow)}"

[ -z "$window" ] && exit 1

last=$(ls "$dir" | grep -E "^screen[0-9]{5}\.png$" | sort | tail -1)
import -window $window $dir/screen$(printf "%.5d" $(( 10#${last:6:5} + 1 ))).png
