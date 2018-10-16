#!/bin/bash

isoff=`amixer -c 0 cget name='Internal Mic Playback Switch' | tail -1 | grep off`

if [ -n "$isoff" ]; then
    micon
else
    micoff
fi
