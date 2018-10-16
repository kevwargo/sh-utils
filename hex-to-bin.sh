#!/bin/bash

[ -z "$1" ] && echo "usage: $0 filename (use /dev/stdin for piping)" && exit 1
file="$1"

echo -ne $(cat "$file" | sed -e 's/../\\x&/g')
