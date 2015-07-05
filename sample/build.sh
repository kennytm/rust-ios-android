#!/bin/sh

set -euo pipefail

# Build the rust project.

cd cargo
../../cargo-all-targets.py clean
../../cargo-all-targets.py build-lib --release

# Convert to iOS library
../../ios-fat-lib.sh release libsample

cd ../android

gradle assembleRelease

cd ../ios

xcodebuild

