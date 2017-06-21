# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::mozilla::generic_worker {
    anchor {
        'packages::mozilla::generic_worker::begin': ;
        'packages::mozilla::generic_worker::end': ;
    }

    $tag = 'v8.5.0'

    # Binaries should be downloaded from
    # https://github.com/taskcluster/generic-worker/releases/download/${tag}/generic-worker-${os}-${arch}
    # to /data/repos/EXEs/generic-worker-${tag}-${os}-${arch}

    Anchor['packages::mozilla::generic_worker::begin'] ->
    case $::operatingsystem {
        Darwin: {
            file {
                '/usr/local/bin/generic-worker':
                    source => "puppet:///repos/EXEs/generic-worker-${tag}-darwin-amd64",
                    mode   => '0755',
                    owner  => root,
                    group  => wheel,
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    } -> Anchor['packages::mozilla::generic_worker::end']
}

