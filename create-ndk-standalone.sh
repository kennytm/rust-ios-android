#!/bin/sh

set -euo pipefail

if [ -d NDK ]; then
    printf '\e[33;1mStandalone NDK already exists... Delete the NDK folder to make a new one.\e[0m\n\n'
    printf '$ rm -rf NDK\n'
    exit 0
fi

NDK_VERSION=$(brew cask info android-ndk | head -1 | cut -d' ' -f 2)
MAKER="/usr/local/opt/android-ndk/android-ndk-r${NDK_VERSION}/build/tools/make_standalone_toolchain.py"

if [ -x "$MAKER" ]; then
    echo 'Creating standalone NDK...'
else
    printf '\e[91;1mPlease install `android-ndk`!\e[0m\n\n'
    printf '$ brew cask install android-ndk\n'
    exit 1
fi

mkdir NDK
cd NDK

for ARCH in arm64 arm x86; do
    echo "($ARCH)..."
    "$MAKER" --arch $ARCH --install-dir $ARCH
done

echo 'Updating cargo-config.toml...'

cd ..
sed 's|$PWD|'"${PWD}"'|g' cargo-config.toml.template > cargo-config.toml

