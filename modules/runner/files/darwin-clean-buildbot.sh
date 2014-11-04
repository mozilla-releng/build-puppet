#! /bin/sh
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# remove the semaphore file that was causing this process to run
rm -rf /var/tmp/semaphore/run-buildbot

# Pre-flight cleanup
if [ "${TMPDIR}" != "" ]; then
  rm -rf ${TMPDIR}/*
fi
rm -rf /Users/cltbld/Library/Caches/TemporaryItems/*
rm -rf /Users/cltbld/.Trash/*
rm -rf /Users/cltbld/Downloads/*

echo "$(basename $0): finished buildslave cleanup $(date)"

exit 0
