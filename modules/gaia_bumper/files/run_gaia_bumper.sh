#!/bin/bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# This file is managed by puppet
set -e
cd /builds/gaia_bumper
exec >> gaia_bumper.log 2>&1

function log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') pid-$$ $*"
}
log "Acquiring lock"
lockfile -s60 -r5 gaia_bumper.lock
trap "rm -f $PWD/gaia_bumper.lock" EXIT

# Get mozharness updated / checked out and working
log "Updating mozharness"
timeout 300 /usr/local/bin/hgtool.py -b production https://hg.mozilla.org/build/mozharness mozharness
log "Running gaia bumper"
python mozharness/scripts/bump_gaia_json.py -c gaia_bumper/gaia_json.py
# Touch our timestamp file so nagios can check if we're fresh
touch gaia_bumper.stamp
log "Done"
