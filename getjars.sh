#!/bin/bash

while [[ $# > 0 ]]; do
    case $1 in
        -r )
            recursive=yes
            ;;
        -f )
            find_opts="$2"
            shift
            ;;
        * )
            dir="$1"
            ;;
    esac
    shift
done

[ -z "$dir" ] && exit 1

[ -z "$find_opts" ] && find_opts="-name \"*.jar\""
[ -z $recursive ] && find_opts="-maxdepth 1 $find_opts"

cp="$(eval find "$dir" $find_opts | tr '\n' ':')"

[ -n "$cp" ] && echo ${cp::-1} || exit 0
