#!/usr/bin/env python3

import subprocess
import collections
import os.path
import os
import sys
import shlex

CUR_PATH = os.path.dirname(__file__)

TARGETS = [
    (None, {}),
    ('arm-linux-androideabi', {
        'AR': os.path.join(CUR_PATH, 'NDK', 'bin', 'arm-linux-androideabi-ar'),
        'CC': os.path.join(CUR_PATH, 'NDK', 'bin', 'arm-linux-androideabi-gcc'),
    }),
    ('i386-apple-ios', {
        'IPHONEOS_DEPLOYMENT_TARGET': '8.0',
    }),
    ('x86_64-apple-ios', {
        'IPHONEOS_DEPLOYMENT_TARGET': '8.0',
    }),
    ('armv7-apple-ios', {
        'IPHONEOS_DEPLOYMENT_TARGET': '8.0',
    }),
    ('armv7s-apple-ios', {
        'IPHONEOS_DEPLOYMENT_TARGET': '8.0',
    }),
    ('aarch64-apple-ios', {
        'IPHONEOS_DEPLOYMENT_TARGET': '8.0',
    }),
]

def crate_type(target):
    if target and 'android' in target:
        return 'dylib'
    else:
        return 'staticlib'


for target, env in TARGETS:
    print('\033[36;1m<<', target, '>>\033[0m')

    new_env = dict(os.environ)
    new_env.update(env)

    args = list(sys.argv)
    args[0] = 'cargo'

    try:
        if args[1] == 'build-lib':
            args[1] = 'rustc'
            args.extend(['--', '--crate-type', crate_type(target)])
    except IndexError:
        pass

    if target:
        args.insert(2, '--target=' + target)

    if '--verbose' in sys.argv:
        for key, val in env.items():
            print('{}="{}"'.format(key, shlex.quote(val)), end=' ')
        print(*map(shlex.quote, args))

    subprocess.call(args, env=new_env)


