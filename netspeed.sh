#!/bin/bash

while true; do 
    nfacct list
    echo --------------------------- > /dev/stderr
    sleep 1
done | awk -F ';| ' '{ if ($10 in spd) printf("%-10s  %-15d %-10d\n", $10, $7, $7 - spd[$10]); spd[$10] = $7; }'
