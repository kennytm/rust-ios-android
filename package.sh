#!/bin/sh

set -euo pipefail

TODAY=$(date -ju "+%Y-%m-%d")
VERSION=${1-nightly}

tar cfvJ "rust-ios-android-${VERSION}-${TODAY}.tar.xz" "build-${VERSION}/x86_64-apple-darwin/stage2"

