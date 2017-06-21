# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::mozilla::taskcluster_host_secrets {
    anchor {
        'packages::mozilla::taskcluster_host_secrets::begin': ;
        'packages::mozilla::taskcluster_host_secrets::end': ;
    }

    $version = '1.1.2-1.fc25'

    # RPM packages are uploaded to the Puppet Yum repositories at:
    # /data/repos/yum/custom/taskcluster/x86_64/taskcluster-host-secrets-${version}.x86_64.rpm

    Anchor['packages::mozilla::taskcluster_host_secrets::begin'] ->
    case $::operatingsystem {
        CentOS: {
            case $::operatingsystemmajrelease {
                6: {
                    realize(Packages::Yumrepo['taskcluster'])
                    package {
                        'taskcluster-host-secrets':
                            ensure => $version;
                    }
                }
                default: {
                    fail("Cannot install on ${::operatingsystem} version ${::operatingsystemmajrelease}")
                }
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    } -> Anchor['packages::mozilla::taskcluster_host_secrets::end']
}
