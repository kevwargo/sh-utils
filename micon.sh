#!/bin/bash

amixer -c 0 cset name='Internal Mic Playback Switch' on,on &>/dev/null
