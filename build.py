#!/usr/bin/env python3

import enum
import datetime
import hashlib
import os.path
import shutil
import subprocess
import sys
import tarfile
import urllib.request



class LogStatus(enum.Enum):
    '''Simple log message reporting routine.
    '''
    error = 91
    info = 32
    warn = 31

    def __call__(self, msg, extra=''):
        print('\033[', self.value, ';1m', msg, '\033[0m ', extra, sep='')



def get_version():
    '''Obtains the rustc version specified by the user.
    '''
    try:
        return sys.argv[1]
    except IndexError:
        return 'nightly'



def sha256(filename):
    '''Computes the SHA-256 checksum of a file. Returns the hex digest.
    '''
    m = hashlib.sha256()
    with open(filename, 'rb') as f:
        while True:
            data = f.read(1024)
            if data:
                m.update(data)
            else:
                break
    return m.hexdigest()



def download(url, filename):
    '''Downloads a binary file to a local path.

    This method reports the download progress when using a tty.
    '''
    with urllib.request.urlopen(url) as src, open(filename, 'wb') as target:
        buf = memoryview(bytearray(1024*16))
        total_bytes_read = 0
        total_size = int(src.getheader('Content-Length', 0))
        print('{}: {:.1f} MiB'.format(url, total_size / 1048576))
        while True:
            bytes_read = src.readinto(buf)
            if bytes_read > 0:
                total_bytes_read += bytes_read
                print('({:6.1%})'.format(total_bytes_read / total_size), end='\r')
                target.write(buf[:bytes_read])
            else:
                break
        print('( Done )')



def source_code_archive_filename(version):
    '''Gets the filename of the source-code archive (rustc-xxxx-src.tar.gz)
    '''
    return 'rustc-' + version + '-src.tar.gz'



def source_code_folder_filename(version):
    '''Gets the name of the folder to store the extracted rustc source code.
    '''
    return 'rustc-' + version



def build_folder_filename(version):
    '''Gets the name of the folder to store the built rustc compilers.
    '''
    return 'build-' + version



def channel(version):
    '''Convert the concrete version name to the expected release channel.
    '''
    if version == 'nightly':
        return 'nightly'
    elif 'beta' in version:
        return 'beta'
    else:
        return 'stable'


def download_source_code(version):
    '''Downloads the source code tarball for the specified version.
    '''
    filename = source_code_archive_filename(version)
    source_url = 'https://static.rust-lang.org/dist/' + filename
    with urllib.request.urlopen(source_url + '.sha256') as f:
        expected_sha256 = f.read(64).decode()

    if os.path.isfile(filename):
        if sha256(filename) == expected_sha256:
            LogStatus.info('Reusing existing archive')
            return

    LogStatus.warn('Going to download source archive...')
    download(source_url, filename)

    if sha256(filename) != expected_sha256:
        LogStatus.error('Checksum incorrect! Check your network connection?')
        sys.exit(1)

    source_folder = source_code_folder_filename(version)
    shutil.rmtree(source_folder)



def extract_source_code(version):
    '''Extracts the source code tarball for the specified version.

    It is assumed the tarball has already been downloaded using
    `download_source_code()`.
    '''
    filename = source_code_archive_filename(version)
    source_folder = source_code_folder_filename(version)
    LogStatus.info('Extracting ' + filename)
    with tarfile.open(filename) as f:
        f.extractall()
        with open(os.path.join(source_folder, '.gitmodules'), 'a'):
            pass



def download_cargo():
    '''Downloads the latest version of cargo.

    Cargo does not have a release train. This function will always download the
    source code of the latest development version.
    '''
    LogStatus.info('Updating cargo')
    if os.path.isdir('cargo/.git'):
        subprocess.check_call(['git', 'checkout', 'master'], cwd='cargo')
        subprocess.check_call(['git', 'pull', 'origin', 'master'], cwd='cargo')
    else:
        subprocess.check_call(['git', 'clone', 'git://github.com/rust-lang/cargo.git', '--depth', '1'])



def compile_rustc(version):
    '''Compile the rustc cross-compilers.
    '''
    build_folder = build_folder_filename(version)
    os.makedirs(build_folder, exist_ok=True)
    LogStatus.info('Compiling rustc...', '(may take ~60 minutes)')
    if not os.path.isfile(os.path.join(build_folder, 'config.mk')):
        src_folder = source_code_folder_filename(version)
        ndk_folder = os.path.abspath('NDK')
        configure_file = os.path.join('..', src_folder, 'configure')
        subprocess.check_call([configure_file,
            '--target=arm-linux-androideabi,armv7-apple-ios,armv7s-apple-ios,aarch64-apple-ios,i386-apple-ios,x86_64-apple-ios,x86_64-apple-darwin',
            '--disable-valgrind-rpass',
            '--disable-docs',
            '--disable-optimize-tests',
            '--disable-llvm-assertions',
            '--enable-fast-make',
            '--enable-ccache',
            '--android-cross-path=' + ndk_folder,
            '--disable-jemalloc',
            '--enable-clang',
            '--release-channel=' + channel(version),
        ], cwd=build_folder)

    start_time = datetime.datetime.now()
    subprocess.check_call(['make', 'all', '-j3', 'NO_BUILD=1'], cwd=build_folder)
    end_time = datetime.datetime.now()
    duration = end_time - start_time
    LogStatus.info('Time taken: ' + str(duration))



def compile_cargo(version):
    build_folder = build_folder_filename(version)
    rustc_root = os.path.join(build_folder, 'x86_64-apple-darwin', 'stage2')
    rustc_root = os.path.abspath(rustc_root)

    subprocess.check_call(['./configure',
        '--disable-cross-tests',
        '--local-rust-root=' + rustc_root
    ], cwd='cargo')

    make_result = subprocess.call(['make'], cwd='cargo')
    if make_result == 0:
        source_file = os.path.join('cargo', 'target', 'x86_64-apple-darwin', 'debug', 'cargo')
    else:
        LogStatus.warn('Cannot build cargo, copying the snapshot instead.', '(see https://github.com/rust-lang/cargo/issues/1479)')
        source_file = os.path.join('cargo', 'target', 'snapshot', 'cargo', 'bin', 'cargo')
    target_folder = os.path.join(rustc_root, 'bin')
    shutil.copy2(source_file, target_folder)



def main():
    version = get_version()
    download_source_code(version)
    extract_source_code(version)
    download_cargo()
    compile_rustc(version)
    compile_cargo(version)
    LogStatus.info('Done')



if __name__ == '__main__':
    main()

