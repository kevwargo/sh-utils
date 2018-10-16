#!/bin/bash

[ -z "$(echo "$1" | grep '^[0-9]\+$')" ] && exit 1
port=$1
shift

if [ $# -eq 0 ]; then
    exec python3 -i -c "import sys; sys.path.append('/mnt/develop/my/programming/python/modules'); import pyexecserver; pyexecserver.start($port, globals())"
else
    exec python3 /mnt/develop/my/programming/python/pyexecserver.py $port "$@"
fi
