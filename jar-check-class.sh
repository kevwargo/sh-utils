#!/bin/bash

jar="$1"
class="$2"

[ -z "$jar" -o -z "$class" ] && exit 1

unzip -l "$jar" 2>/dev/null | grep -q "$class" && echo "$jar"
