rust-ios-android
================

Example project for building a library for iOS + Android in Rust. Mac OS X is
required (because iOS).

* ✓ Rust 1.14 – 1.17
* ✓ Android 4.1 – 7.1 (API 16–25)
* ✓ iOS 7.0 – 10.3

<small>(probably works on earlier versions but I don't bother to check 😛)</small>

*Note: The purpose of this project is not to create a pure Rust app, but rather
use Rust as a shared native component between the mobile platforms.*

You may also want to check <https://github.com/Geal/rust_on_mobile>.

Setup
-----

1. Get Xcode, and install the command line tools.

    ```sh
    xcode-select --install
    ```

* Get Android NDK. We recommend installing it with [homebrew](http://brew.sh/).

    ```sh
    brew cask install android-ndk
    ```

* Create the standalone NDKs.

    ```sh
    ./create-ndk-standalone.sh
    ```

* Download [rustup](https://www.rustup.rs/). We will use this to setup Rust for
   cross-compiling.

    ```sh
    curl https://sh.rustup.rs -sSf | sh
    ```

* Install the stable build of rust.

    ```sh
    rustup install stable
    ```

* Download targets for iOS and Android.

    ```sh
    # Note: you need *all* five targets
    rustup target add aarch64-apple-ios armv7-apple-ios armv7s-apple-ios x86_64-apple-ios i386-apple-ios
    rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android
    ```

* Copy the content of `cargo-config.toml` (consists of linker information of
   the Android targets) to `~/.cargo/config`

    ```sh
    cat cargo-config.toml >> ~/.cargo/config
    ```

* Install cargo-lipo to generate the iOS universal library.

    ```sh
    cargo install cargo-lipo
    ```

Creating the libraries
----------------------

You use use the `sample/` project as an example. (Note that the sample itself
does not contain proper error checking.)

1. Write the library and expose a C interface. See [the FFI chapter in the Rust
   Book](http://doc.rust-lang.org/book/ffi.html) for an introduction.

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
    xctool -configuration Release -scheme RustSample
    cd ../..
    ```

    When you create an Xcode project yourself, note the following points:

    * Add the C header `rust_regex.h` to allow using the Rust functions from C.
    * Copy `target/universal/release/lib???.a` to the project. You may need
      to modify LIBRARY_SEARCH_PATHS to include the folder of the `*.a` file.
    * Note that cargo-lipo does not generate bitcode yet. You must set
      ENABLE_BITCODE to NO. (See also <http://stackoverflow.com/a/38488617>)

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
