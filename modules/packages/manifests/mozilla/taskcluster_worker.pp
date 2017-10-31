# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::mozilla::taskcluster_worker {
    include ::users::root

    anchor {
        'packages::mozilla::taskcluster_worker::begin': ;
        'packages::mozilla::taskcluster_worker::end': ;
    }

    $version = '0.1.10'

    # Binaries should be downloaded from
    # https://github.com/taskcluster/taskcluster-worker/releases/download/${version}/taskcluster-worker-${plat}
    # to /data/repos/EXEs/taskcluster-worker-${version}-${plat}

    Anchor['packages::mozilla::taskcluster_worker::begin'] ->
    case $::operatingsystem {
        Darwin: {
            file {
                '/usr/local/bin/taskcluster-worker':
                    source => "puppet:///repos/EXEs/taskcluster-worker-${version}-darwin-amd64",
                    mode   => '0755',
                    owner  => $::users::root::username,
                    group  => $::users::root::group,
            }
        }
        Ubuntu, Fedora, CentOS: {
            file {
                '/usr/local/bin/taskcluster-worker':
                    source => "puppet:///repos/EXEs/taskcluster-worker-${version}-linux-amd64",
                    mode   => '0755',
                    owner  => $::users::root::username,
                    group  => $::users::root::group,
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    } -> Anchor['packages::mozilla::taskcluster_worker::end']
}

