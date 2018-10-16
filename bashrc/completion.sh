#!/bin/bash

# This function checks whether we have a given program on the system.
#
_have()
{
    # Completions for system administrator commands are installed as well in
    # case completion is attempted via `sudo command ...'.
    PATH=$PATH:/usr/sbin:/sbin:/usr/local/sbin type $1 &>/dev/null
}

# Backwards compatibility for compat completions that use have().
# @deprecated should no longer be used; generally not needed with dynamically
#             loaded completions, and _have is suitable for runtime use.
have()
{
    unset -v have
    _have $1 && have=yes
}

if ! uname -a | grep -q Ubuntu; then
    compl_dir="./completions"
    [[ $BASH_SOURCE == */* ]] && compl_dir="${BASH_SOURCE%/*}/completions"
    if [ -d $compl_dir ]; then
        for file in $(ls "$compl_dir/gentoo" | grep "^[[:alnum:]].*[^\~]$"); do
            . "$compl_dir/gentoo/$file"
        done
        . "$compl_dir/init-ubuntu"
        . "$compl_dir/ubuntu/man"
    fi
    unset compl_dir
fi
