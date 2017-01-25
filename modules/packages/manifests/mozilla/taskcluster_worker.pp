# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::mozilla::taskcluster_worker {
    anchor {
        'packages::mozilla::taskcluster_worker::begin': ;
        'packages::mozilla::taskcluster_worker::end': ;
    }

    $version = '0.0.7'

    # Binaries should be downloaded from
    # https://github.com/taskcluster/taskcluster-worker/releases/download/${version}/taskcluster-worker-${plat}
    # to /data/repos/EXEs/taskcluster-worker-${version}-${plat}

    Anchor['packages::mozilla::taskcluster_worker::begin'] ->
    case $::operatingsystem {
        Darwin: {
            file {
                '/usr/local/bin/taskcluster-worker':
                    source => "puppet:///repos/EXEs/taskcluster-worker-${version}-darwin-amd64",
                    mode => 0755,
                    owner => root,
                    group => wheel,
            }
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    } -> Anchor['packages::mozilla::taskcluster_worker::end']
}

