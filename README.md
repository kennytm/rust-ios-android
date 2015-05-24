rust-ios-android
================

Example project for building static library for iOS + Android in Rust. Mac OS X is required (because iOS).

*Note: The purpose of this project is not to create a pure Rust app, but rather use Rust as a shared native component between the mobile platforms.*

Usage
-----

1. Download [multirust](https://github.com/brson/multirust). We will use this later to create a "virtual environment" of our Rust cross-compiler.

    ```sh
    $ curl -sf https://raw.githubusercontent.com/brson/multirust/master/blastoff.sh | sh
    ```

2. Get Xcode, and install the command line tools.

3. Get Android NDK r10e. We recommend installing it with [homebrew](http://brew.sh/).

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

6. Build Rust and Cargo. It will automatically download the latest published nightly source. You may also specify a version from the beta/stable channel. (This step is slow)

    ```sh
    $ ./build.py                # Build with latest published nightly

    # -- or --

    $ ./build.py 1.1.0-beta.2   # Build with a beta version

    # -- or --

    $ ./build.py 1.0.0          # Build with a stable version
    ```

7. Register this new toolchain with `multirust`.

    ```sh
    $ multirust update mobile-nightly --link-local ./build-nightly/x86_64-apple-darwin/stage2
    ```

8. Use `package.sh` to distribute the compiler as an `*.xz` package. (This step is slow and is optional)

    ```sh
    $ ./package.sh nightly
    ```

9. Copy the content of `cargo-config.toml` into `~/.cargo/config`.

10. Whenever you want to run `cargo` on all targets, use the script `cargo-all-targets.py`, e.g.

    ```sh
    $ /...path-to.../rust-ios-android/cargo-all-targets.py build --release
    ```

11. For iOS, use `ios-fat-lib.sh` to combine several `*.a` files into a fat static library.


