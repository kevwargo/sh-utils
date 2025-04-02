#!/bin/bash

set -e

dir=$(realpath ~/screens)
name=screen_$(date "+%Y-%m-%d_%H-%M-%S.%6N%z").png
path="$dir/$name"

mkdir -p $dir
import "$@" "$path"

echo "$path"
