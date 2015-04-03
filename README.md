rust-ios-android
================

Example project for building static library for iOS + Android in Rust.

*Note: The purpose of this project is not to create a pure Rust app, but rather use Rust as a shared native component between the mobile platforms.*

Usage
-----

1. Download [multirust](https://github.com/brson/multirust). We will use this later to create a "virtual environment" of our Rust cross-compiler.

    ```sh
    $ curl -sf https://raw.githubusercontent.com/brson/multirust/master/blastoff.sh | sh
    ```

2. Get Xcode, and install the command line tools.

3. Get Android NDK. We recommend installing it with [homebrew](http://brew.sh/).

    ```sh
    $ brew install android-ndk
    ```

4. Get Python 3.

    ```sh
    $ brew install python3
    ```

5. Create a *standalone toolchain* from the NDK.

    ```sh
    $ ./create-ndk-standalone.sh
    ```

6. Build Rust and Cargo. It will automatically download the published nightly source of today (in UTC).

    ```sh
    $ ./build.sh
    ```

7. Register this new toolchain with `multirust`.

    ```sh
    $ multirust update mobile --link-local ./build/x86_64-apple-darwin/stage2
    ```

8. Copy `cargo-config.toml` to `~/.cargo/config`, and edit the content so the linker and ar point to correct paths.

9. Whenever you want to run `cargo` on all targets, use the script `cargo-all-targets.py`, e.g.

    ```sh
    $ /...path-to.../rust-ios-android/cargo-all-targets.py build --release
    ```

10. For iOS, use `ios-fat-lib.sh` to combine several `*.a` files into a fat static library.

