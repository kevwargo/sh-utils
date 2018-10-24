#!/bin/bash

ps1_newline_on()
{
    export ps1_part_2="$(echo "$ps1_part_2" | sed 's/^\\\[/\\n \\[/')"
}

ps1_newline_off()
{
    export ps1_part_2="$(echo "$ps1_part_2" | sed 's/^\\n //')"
}

if [ $UID == 0 ]; then
    ps1_part_1='\[\033[01;31m\]\h\[\033[01;34m\] \w\[\033[00m\]'
else
    ps1_part_1='\[\033[01;32m\]\h\[\033[01;34m\] \w\[\033[00m\]'
fi
ps1_part_2='\[\033[01;34m\]\$\[\033[00m\] '

export PS1="$ps1_part_1 $ps1_part_2"

