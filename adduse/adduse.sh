#!/bin/bash

default=/etc/portage/package.use
if ! [ -f $default ]; then
    mkdir -p $default
    [ -z "$(ls -A $default)" ] && > $default/package.use
    default="${default}/$(ls -A $default | sort -V | tail -1)"
fi

progname=$(basename "$0")
progdir=$(dirname $(realpath "$0"))

while ! [ -z "$1" ]; do
    case "$1" in
        "-i" ) shift; infile="$1"; shift ;;
        "-o" ) shift; outfile="$1"; shift ;;
        "-e" ) infile=/dev/null; shift ;;
        "-c" ) outfile=/dev/stdout; shift ;;
        "-p" ) infile=/dev/stdin; shift ;;
        "-h" | "--help" )
            echo -n "Util for "
            [[ "$progname" == "adduse" ]] && echo -n "add useflags and "
            [[ "$progname" == "deluse" ]] && echo -n "remove useflags and "
            echo "normalize package.use (or custom file, see below)"
            echo "$progname [OPTIONS] PACKAGE USEFLAG1 [USEFLAGS...]"
            echo
            echo "Options:"
            echo "-h | --help   print this text and exit"
            echo "-i FILE       specify input file (default $default) (same as out-file if not specified) (specify dash to use /dev/stdin)"
            echo "-o FILE       specify output file (default $default)"
            echo "-e            use empty input file (alias for '-i /dev/null')"
            echo "-c            use pipe output (alias for '-o /dev/stdout')"
            exit 0
            ;;
        * )
        if [ -z $pkg ]; then
            pkg=$1
            shift
        else
            uses+="$1 "
            shift
        fi
        ;;
    esac
done

outfile="${outfile:-$default}"
infile="${infile:-$outfile}"

if [[ "$infile" == "$outfile" ]]; then
    tmp=`tempfile`
    cp "$infile" $tmp
fi

if [[ "$pkg" != *"/"* ]]; then
    if [ -f /etc/make.conf ]; then
        makeconf="/etc/make.conf"
    elif [ -f /etc/portage/make.conf ]; then
        makeconf="/etc/portage/make.conf"
    else
        echo "ERROR: Coundn't find make.conf for resolving package category!!!"
        exit 1
    fi
    portdirs="$(source $makeconf && echo "$PORTDIR $PORTDIR_OVERLAY")"
    found="$(find $portdirs -mindepth 2 -maxdepth 2 -type d -name $pkg)"
    for path in $(echo $found | tr ' ' '\n' | grep "^.*/[^/]*-[^/]*/[^/]*$"); do
        if [ -z "$category" ]; then
            category=$(basename $(dirname $path))
        else
            disambiguous=t
            category+=" $(basename $(dirname $path))"
        fi
    done
    if [ -n "$disambiguous" ]; then
        echo "Package name $pkg is disambiguous, please specify what package of theese you meant:"
        for c in $category; do
            echo $c/$pkg
            # echo
        done
        exit 1
    fi
    if [ -z "$category" ]; then
        echo "Couldn't find package $pkg in $portdirs"
        exit 3
    fi
    pkg=$category/$pkg
fi

grep -vE "(^[[:space:]]*#|^$)" ${tmp:-"$infile"} | sort | awk -v pkg="$pkg" \
    -v uses="$uses" -v progname=$(basename "$0") -f "${progdir}/adduse.awk" > "$outfile"

[ -z $tmp ] || rm $tmp
