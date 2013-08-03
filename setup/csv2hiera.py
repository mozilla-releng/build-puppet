#! /usr/bin/env python

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# note that this script requires both rubygem-hiera-eyaml and PyYAML to be installed.
# just yum install them.

import csv
import sys
import subprocess
import yaml

do_not_encode = [
    'network_regexps'
]

def encode(name, secret):
    if name in do_not_encode or name.endswith('_username') or name.endswith('_hostname') or name.endswith('_database'):
        return secret
    p = subprocess.Popen(['eyaml', '-o', 'string', '-e'], stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    return p.communicate(input=secret)[0].strip()

rv = {}

for secret_line in csv.reader(open(sys.argv[1])):
    if not secret_line:
        continue
    name = secret_line[0]
    secrets = secret_line[1:]
    if len(secrets) > 1:
        rv[name] = [ encode(name, s) for s in secrets ]
    elif secrets[0] == '':
        continue
    else:
        rv[name] = encode(name, secrets[0])

print yaml.dump(rv, default_flow_style=False, explicit_start=True)
