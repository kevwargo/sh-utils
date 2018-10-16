#!/bin/bash

mappername="$1"; shift

offset=0
minor=0
while ! [ -z "$1" ]; do
    if ! [ -b "$1" ]; then
        if losetup -f &> /dev/null; then
            loopdev=$(losetup -f)
            minor=0x$(stat -c %T $loopdev)
        else
            while true; do
                if mknod /dev/loop$minor b 7 $minor &> /dev/null; then
                    losetup -f &> /dev/null && break || minor=$(( $minor+1 ))
                else
                    minor=$(( $minor+1 ))
                fi
            done
            loopdev=$(losetup -f)
        fi
        unset minor
        echo "$loopdev $1" > /dev/stderr
        losetup -v $loopdev $1 > /dev/stderr
    else
        loopdev=$1
    fi
    size=$(blockdev --getsz $loopdev)
    echo "$offset $size linear $loopdev 0"
    echo "$offset $size linear $loopdev 0" > /dev/stderr
    offset=$(( $offset+$size ))
    shift
done | dmsetup create $mappername
