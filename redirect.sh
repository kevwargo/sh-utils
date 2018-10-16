#!/bin/bash

[ $# -lt 3 ] && exit 1

pid="$1"
out="$2"
err="$3"

echo "p dup2(open(\"$out\", 1089, 438),1)
p dup2(open(\"$err\", 1089, 438),2)
detach
quit" | gdb -p $pid
