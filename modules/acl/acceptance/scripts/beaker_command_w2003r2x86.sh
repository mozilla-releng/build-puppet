#!/bin/bash

beaker \
  --pre-suite ../setup/pe_install.rb \
  --config ../config/windows-2003r2-i386.cfg \
  --debug \
  --tests ../tests \
  --keyfile ~/.ssh/id_rsa-acceptance \
  --preserve-hosts onfail \
  --timeout 6000
