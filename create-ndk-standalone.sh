#!/bin/sh

set -euo pipefail

## Create an Android NDK Standalone toolchain.

MAKER=/usr/local/Cellar/android-ndk/r12/build/tools/make_standalone_toolchain.py

if [ -d NDK ]; then
    exit 0
fi

echo 'Creating standalone NDK...'

mkdir NDK
cd NDK

if [ -x "$MAKER" ]; then
    for ARCH in arm64 arm x86; do
        echo "($ARCH)..."
        "$MAKER" --arch $ARCH --install-dir $ARCH
    done
else
    printf '\e[91mPlease install `android-ndk` r12!\e[0m\n\n'
    printf '$ brew install android-ndk\n'
    exit 1
fi

echo 'Updating cargo-config.toml...'

cd ..
sed 's|$PWD|'"${PWD}"'|g' cargo-config.toml.template > cargo-config.toml

