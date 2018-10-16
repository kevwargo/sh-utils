#!/bin/bash
BR_FILE=/sys/devices/platform/acer-wmi/backlight/acer-wmi/brightness
if [ -f $BR_FILE ]; then
    CUR_BRIGHT=`cat $BR_FILE`
    [ $1 = + ] && [[ $CUR_BRIGHT < 9 ]] && echo $(( $CUR_BRIGHT + 1 )) > $BR_FILE
    [ $1 = - ] && [[ $CUR_BRIGHT > 0 ]] && echo $(( $CUR_BRIGHT - 1 )) > $BR_FILE
    [[ $1 > 0 ]] && [[ $1 -lt 10 ]] && echo $1 > $BR_FILE
fi