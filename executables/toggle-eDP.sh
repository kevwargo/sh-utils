#!/bin/bash

for f in $(find /sys/devices/pci0000:00/ -path "*/drm/*eDP*/*/brightness"); do
    if [ -z "$brfile" ]; then
        brfile="$f"
    else
        echo "Ambiguous brighness files: $brfile and $f" >/dev/stderr
        exit 1
    fi
done

if [ -z "$brfile" ]; then
    echo "Brighness file not found" >/dev/stderr
    exit 1
fi

backup_file=/run/eDP-brightness-backup
current=$(cat $brfile)
if [ $current -eq 0 ]; then
    [ -f $backup_file ] && cat $backup_file > $brfile
else
    cat $brfile > $backup_file
    echo 0 > $brfile
fi
