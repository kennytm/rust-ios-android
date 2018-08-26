rust-ios-android
================

[![Build status](https://travis-ci.org/kennytm/rust-ios-android.svg?branch=master)](https://travis-ci.org/kennytm/rust-ios-android/)

Example project for building a library for iOS + Android in Rust. macOS is
required for iOS development.

* ✓ Rust 1.20 – 1.25
* ✓ Android 4.1 – 8.1 (Jelly Bean – Oreo) (API 16–27)
* ✓ iOS 7 – 11

<small>(probably works on earlier versions but I don't bother to check 😛)</small>

*Note: The purpose of this project is not to create a pure Rust app, but rather
use Rust as a shared native component between the mobile platforms.*

You may also want to check <https://github.com/Geal/rust_on_mobile>.

Setup
-----

1. Install the common build tools like C compiler and linker. On macOS, get
    Xcode, and install the command line tools.

    ```sh
    xcode-select --install
    ```

2. Get Android NDK. We recommend installing it via Android Studio or
    `sdkmanager`:

    ```sh
    sdkmanager --verbose ndk-bundle
    ```

    Otherwise, please define the environment variable `$ANDROID_NDK_HOME` to the
    path of the current version of Android NDK.

    ```sh
    export ANDROID_NDK_HOME='/usr/local/opt/android-ndk/android-ndk-r14b/'
    ```

3. Create the standalone NDKs.

    ```sh
    ./create-ndk-standalone.sh
    ```

4. Download [rustup](https://www.rustup.rs/). We will use this to setup Rust for
   cross-compiling.

    ```sh
    curl https://sh.rustup.rs -sSf | sh
    ```

5. Download targets for iOS and Android.

    ```sh
    # iOS. Note: you need *all* five targets
    rustup target add aarch64-apple-ios armv7-apple-ios armv7s-apple-ios x86_64-apple-ios i386-apple-ios

    # Android.
    rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android
    ```

6. Copy the content of `cargo-config.toml` (consists of linker information of
   the Android targets) to `~/.cargo/config`

    ```sh
    cat cargo-config.toml >> ~/.cargo/config
    ```

7. Install cargo-lipo to generate the iOS universal library.

    ```sh
    cargo install cargo-lipo
    ```

Creating the libraries
----------------------

You use use the `sample/` project as an example. (Note that the sample itself
does not contain proper error checking.)

1. Write the library and expose a C interface. See [the FFI chapter in the Rust
   Book](https://doc.rust-lang.org/book/first-edition/ffi.html) for an
   introduction.

2. Expose the Java interface with JNI when `target_os="android"`.

3. Build the libraries.

    ```sh
    cd sample/cargo

    # iOS
    cargo lipo --release

    # Android
    cargo build --target aarch64-linux-android --release
    cargo build --target armv7-linux-androideabi --release
    cargo build --target i686-linux-android --release

    cd ../..
    ```

4. Build the Xcode project.

    ```sh
    cd sample/ios
    xcodebuild -configuration Release -scheme RustSample | xcpretty
    cd ../..
    ```

    When you create an Xcode project yourself, note the following points:

    * Add the C header `rust_regex.h` to allow using the Rust functions from C.
    * Copy `target/universal/release/lib???.a` to the project. You may need
      to modify `LIBRARY_SEARCH_PATHS` to include the folder of the `*.a` file.
    * Note that `cargo-lipo` does not generate bitcode yet. You must set
      `ENABLE_BITCODE` to `NO`. (See also <http://stackoverflow.com/a/38488617>)
    * You need to link to `libresolv.tbd`.

5. Build the Android project.

    ```sh
    cd sample/android
    ./gradlew assembleRelease
    cd ../..
    ```

    When you create an Android Studio project yourself, note the following
    points:

    * Copy or link the `*.so` into the corresponding `src/main/jniLibs` folders:

        Copy from Rust | Copy to Android
        ---|---
        `target/armv7-linux-androideabi/release/lib???.so` | `src/main/jniLibs/armeabi-v7a/lib???.so`
        `target/aarch64-linux-android/release/lib???.so` | `src/main/jniLibs/arm64-v8a/lib???.so`
        `target/i686-linux-android/release/lib???.so` | `src/main/jniLibs/x86/lib???.so`

    * Don't forget to ensure the JNI glue between Rust and Java are compatible.
