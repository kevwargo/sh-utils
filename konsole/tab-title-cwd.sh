#!/bin/bash

[ -z "$KONSOLE_DBUS_SERVICE" ] && exit 1

. $(dirname $(realpath "$0"))/lib.sh

set -e

qdbus org.kde.konsole $KONSOLE_DBUS_SESSION setTitle 1 "$PWD"
