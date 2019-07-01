#!/usr/bin/env python3

# Copyright © 2019 Jakub Wilk <jwilk@jwilk.net>
# SPDX-License-Identifier: MIT

import os

import httpolice.parse
import httpolice.syntax.rfc3986

print('1..1')
here = os.path.dirname(__file__)
basedir = '{here}/..'.format(here=here)
path = '{dir}/README'.format(dir=basedir)
url = None
with open(path, 'rt', encoding='UTF-8') as file:
    for line in file:
        if line.startswith(('http:', 'https:')):
            url = line.rstrip('\n')
print('#', url)
httpolice.parse.parse(url, httpolice.syntax.rfc3986.URI)
print('ok 1 - URL syntax check')

# vim:ts=4 sts=4 sw=4 et ft=python
