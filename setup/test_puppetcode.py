#!/usr/bin/env python

import yaml
import pprint
import subprocess

with open(".travis.yml", 'r') as stream:
    try:
        scripts = yaml.load(stream)
        for script in scripts['script']:
            pprint.pprint(script)
            result = subprocess.check_output(script, shell=True, stderr=subprocess.PIPE)
            print result
    except yaml.YAMLError as exc:
        print(exc)
