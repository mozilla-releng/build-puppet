#!/bin/bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# This file is managed by puppet

# All references to files/directories used are absolute to simplify
# troubleshooting, e.g. if someone does a ps to see a process running
# they can see full paths easily, etc

set -eu
exec >> /builds/b2g_bumper/b2g_bumper.log 2>&1

function log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') pid-$$ $*"
}
log "Acquiring lock"
lockfile -s60 -r5 /builds/b2g_bumper/b2g_bumper.lock
trap "rm -f /builds/b2g_bumper/b2g_bumper.lock" EXIT

export PATH=/usr/local/bin:$PATH
env | grep PATH

# Get mozharness updated / checked out and working
log "Updating mozharness"
timeout 300 /usr/local/bin/hgtool.py -b production https://hg.mozilla.org/build/mozharness /builds/b2g_bumper/mozharness

# Clear the cache
rm -f /builds/b2g_bumper/git_ref_cache.json

# Run the bumpers in sequence
all_succeeded=true
for config in $(find /builds/b2g_bumper/mozharness/configs/b2g_bumper/ -type f -name '*.py'); do
    short_name="$(basename "${config}" .py)"
    log "Running b2g bumper using ${config}, log in /builds/b2g_bumper/${short_name}.log"
    mkdir -p "/builds/b2g_bumper/${short_name}"
    if ! python /builds/b2g_bumper/mozharness/scripts/b2g_bumper.py --base-work-dir "/builds/b2g_bumper/${short_name}" -c "${config}" --import-git-ref-cache --push-loop --export-git-ref-cache > "/builds/b2g_bumper/${short_name}.log" 2>&1; then
        all_succeeded=false
    fi
done

if "${all_succeeded}"; then
    log "All branches succeeded, touching /builds/b2g_bumper/b2g_bumper.stamp so nagios knows we're running ok"
    touch /builds/b2g_bumper/b2g_bumper.stamp
else
    log "Failures! Not updating /builds/b2g_bumper/b2g_bumper.stamp"
fi
