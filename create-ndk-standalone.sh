#!/bin/sh

set -euo pipefail

if [ -d NDK ]; then
    exit 0
fi

PREFIX=$(brew --prefix)
TOOL=build/tools/make_standalone_toolchain.py


for candidate in "${PREFIX}/Cellar/android-ndk"/*/"$TOOL"
do
  MAKER="$candidate"                      # Pick last one in ASCIIbetical order
done

if [ -x "$MAKER" ]; then
  echo 'Creating standalone NDK...'
else
  printf '\e[91mPlease install `android-ndk` r12b!\e[0m\n\n'
  printf '$ brew install android-ndk\n'
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

