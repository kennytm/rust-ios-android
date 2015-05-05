#!/bin/sh

set -euo pipefail

## Build a nightly.

ROOT="$PWD"

if [ ! -d NDK ]; then
    ./create-ndk-standalone.sh
fi

TODAY=$(date -ju "+%Y-%m-%d")
URL="http://static.rust-lang.org/dist/rustc-nightly-src.tar.gz"

printf '\e[32;1mDownloading rustc nightly...\e[0m ('$URL')\n'

SHA256=$(curl ${URL}.sha256)
NEEDCURL=0
if [ -f rustc-nightly-src.tar.gz ]; then
    SHA256CHECK=$(shasum -a 256 rustc-nightly-src.tar.gz)
    if [ "$SHA256CHECK" != "$SHA256" ]; then
        printf '\e[91mSHA-256 mismatch, going to re-download!\e[0m\n\n'
        NEEDCURL=1
    fi
else
    NEEDCURL=1
fi
if [ "$NEEDCURL" -eq 1 ]; then
    rm -rf rustc-nightly
    curl -C - -O "$URL"
    SHA256CHECK=$(shasum -a 256 rustc-nightly-src.tar.gz)
    if [ "$SHA256CHECK" != "$SHA256" ]; then
        printf '\e[91mSHA-256 mismatch, check your network!\e[0m\n\n'
        exit 1
    fi
fi
if [ ! -d rustc-nightly ]; then
    tar xfz rustc-nightly-src.tar.gz
    touch rustc-nightly/.gitmodules
fi

printf '\e[32;1mDownloading cargo...\e[0m\n'

if [ -d cargo/.git ]; then
    cd cargo
    git pull origin master
    cd ..
else
    git clone git://github.com/rust-lang/cargo.git --depth 1
fi

printf '\e[32;1mCompiling rustc...\e[0m (may take ~4 hours)\n'

mkdir -p build
cd build
if [ ! -f config.mk ]; then
    ../rustc-nightly/configure \
            --target=arm-linux-androideabi,armv7-apple-ios,armv7s-apple-ios,aarch64-apple-ios,i386-apple-ios,x86_64-apple-ios,x86_64-apple-darwin \
            --disable-valgrind-rpass \
            --disable-docs \
            --disable-optimize-tests \
            --disable-llvm-assertions \
            --enable-fast-make \
            --enable-ccache \
            --android-cross-path="$ROOT/NDK" \
            --disable-jemalloc \
            --enable-clang
fi

"time" make all -j3 NO_REBUILD=1

printf '\e[32;1mCompiling cargo...\e[0m\n'

cd ../cargo
./configure \
        --disable-cross-tests \
        --local-rust-root="$ROOT/build/x86_64-apple-darwin/stage2/"
make
cp ./target/x86_64-apple-darwin/debug/cargo ../build/x86_64-apple-darwin/stage2/bin

printf '\e[32;1mPackaging...\e[0m\n'

cd ..
tar cfJ "rust-ios-android-${TODAY}.tar.xz" build/x86_64-apple-darwin/stage2

printf '\e[32;1mDone.\e[0m\n'

