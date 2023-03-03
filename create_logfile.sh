#!/usr/bin/env bash
set -euo pipefail

if [ $# -eq 0 ] ; then
    >&2 echo 'No arguments supplied'
    exit 1
fi

BASE_DIR=$1

logfile=$BASE_DIR/logfile"_"$(date -u +%Y-%m-%d).log

echo $logfile
