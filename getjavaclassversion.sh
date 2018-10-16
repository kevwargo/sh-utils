#!/bin/bash

filename="$1"

[ -z "$filename" ] && exit 1

echo $(( $(printf "%d" \'$(head -c 8 "$filename" | tail -c 1)) - 44 ))
