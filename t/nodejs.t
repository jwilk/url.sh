#!/usr/bin/env node

// Copyright © 2022 Jakub Wilk <jwilk@jwilk.net>
// SPDX-License-Identifier: MIT

'use strict';

const fs = require('fs');
const process = require('process')

function print(...args)
{
    const s = args.join(' ') + '\n';
    return process.stdout.write(s);
}

const basedir = `${__dirname}/..`;
const path = `${basedir}/README`
const readme = fs.readFileSync(path, 'UTF-8');
print('1..1');
for (const line of readme.split('\n')) {
    if (!line.match('^https?:'))
        break;
    const orig_url = line;
    print('#', orig_url);
    const url = new URL(orig_url);
    if (orig_url === url.href) {
        print('ok 1 - URL syntax check')
    } else {
        print('#', url.href)
        print('not ok 1 - URL syntax check')
    }
};

// vim:ts=4 sts=4 sw=4 et ft=javascript
