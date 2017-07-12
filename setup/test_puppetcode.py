#!/usr/bin/env python
"""This module parse the travis configuration file and execute the commands
    from the script section.
    To run the module, execute: setup/test_puppetcode.py.abs
    Expected results: will display the result for puppet parser validate and
    puppet lint commands. The code is clean if no warnings and no errors wil be displayed"""

import subprocess
import sys

print 'This module parses the travis configuration file and executes the commands',\
      'from the script section\n',\
      'Requirements:\n',\
      '- puppet 3.7.0\n',\
      '- puppet-lint 2.2.1.\n',\
      'If you don\'t have installed puppet and puppet-lint you can install it from gems.\n',\
      'Open a console and run:\n',\
      '- sudo gem install puppet -v 3.7.0\n',\
      '- sudo gem install puppet-lint -v 2.2.1\n'

# Check if pyyaml is installed or not
try:
    # Load yaml module
    import yaml
    # If import yaml is with success, then will display a message that confirm this
    print "Module yaml is installed"
except ImportError:
    # If import failed, display a mesage with rewuired steps and exit from the program
    print 'Module yaml is not installed, the program will stop!!!\n', \
          'To install pyyaml do the followings:\n', \
          '1. Open console;\n', \
          '2. Run sudo pip install pyyaml\n', \
    # Exit from the program, with status code 1
    sys.exit(1)

with open(".travis.yml", 'r') as stream:
    try:
        scripts = yaml.load(stream)
        for script in scripts['script']:
            print script
            # Added the subprocess into try except construction for a better management of errors
            try:
                result = subprocess.check_output(script, shell=True, stderr=subprocess.STDOUT)
                # If script return with no errors, display the result
                print result
            except subprocess.CalledProcessError as e:
                # If the script return the error, this error will be printed on the console. By default, python
                # only notify you that the script had returned a non zero exit
                print e.output
    except yaml.YAMLError as exc:
        print exc