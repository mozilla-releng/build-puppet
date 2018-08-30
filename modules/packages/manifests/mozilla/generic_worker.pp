# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::mozilla::generic_worker {
    anchor {
        'packages::mozilla::generic_worker::begin': ;
        'packages::mozilla::generic_worker::end': ;
    }

    if (has_aspect('staging')) {
        $tag = 'v10.11.3'
    } else {
        $tag = 'v10.11.3'
    }
    $proxy_tag = 'v4.1.1'
    $quarantine_worker_tag = 'v1.0.0'

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
            # install taskcluster proxy, Bug 1452095
            # Binaries should be downloaded from
            # https://github.com/taskcluster/taskcluster-proxy/releases/download/${tag}/taskcluster-proxy-${os}-${arch}
            # to /data/repos/EXEs/taskcluster-proxy-${tag}-${os}-${arch}
            file {
                '/usr/local/bin/taskcluster-proxy':
                    source => "puppet:///repos/EXEs/taskcluster-proxy-${proxy_tag}-darwin-amd64",
                    mode   => '0755',
                    owner  => root,
                    group  => wheel,
            }
            # install quarantine-worker, Bug 1461913
            # Binaries should be downloaded from
            # https://github.com/mozilla-platform-ops/quarantine-worker/releases/download/${tag}/quarantine-worker-${os}-${arch}
            # to /data/repos/EXEs/quarantine-worker-${tag}-${os}-${arch}
            file {
                '/usr/local/bin/quarantine-worker':
                    source => "puppet:///repos/EXEs/quarantine-worker-${quarantine_worker_tag}-darwin-amd64",
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

