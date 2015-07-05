#!/bin/sh

set -euo pipefail

if [ $# -lt 2 ]; then
    printf "Usage: ./ios-fat-lib.sh (debug|release) <libxxx>"
else
    lipo -create -output "${2}-${1}.a" target/*-apple-ios/${1}/${2}*.a
fi

