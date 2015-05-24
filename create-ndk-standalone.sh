#!/bin/sh

set -euo pipefail

## Create an Android NDK Standalone toolchain.

MAKER=/usr/local/Cellar/android-ndk/r10e/build/tools/make-standalone-toolchain.sh

if [ -d NDK ]; then
    exit 0
fi

printf '\e[32;1mCreating standalone NDK...\e[0m\n'

mkdir NDK
cd NDK

if [ -x "$MAKER" ]; then
    "$MAKER" --toolchain=arm-linux-androideabi-4.9 --platform=android-22 --install-dir=.
else
    printf '\e[91mPlease install `android-ndk` r10d!\e[0m\n\n'
    printf '$ brew install android-ndk\n'
    exit 1
fi

printf '\e[32;1mUpdating cargo-config.toml...\e[0m\n'

cd ..
sed 's|$PWD|'"${PWD}"'|g' cargo-config.toml.template > cargo-config.toml

