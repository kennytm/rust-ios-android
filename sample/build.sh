#!/bin/sh

set -euo pipefail

# Build the rust project.
cd cargo
cargo clean
cargo test

cargo lipo --release
cargo build --target aarch64-linux-android --release
cargo build --target armv7-linux-androideabi --release
cargo build --target i686-linux-android --release

# Build the Android project.
cd ../android
gradle assembleRelease

# Build the iOS project.
cd ../ios
xcodebuild
