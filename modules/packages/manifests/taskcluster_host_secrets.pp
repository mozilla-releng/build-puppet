# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::taskcluster_host_secrets {
    case $::operatingsystem {
        CentOS: {
            case $::operatingsystemmajrelease {
                6: {
                    realize(Packages::Yumrepo['taskcluster'])
                    package {
                        "taskcluster-host-secrets":
                            ensure => "1.0.0-1.fc25";
                    }
                }
                default: {
                    fail("cannot install on $::operatingsystem version $::operatingsystemmajrelease")
                }
            }
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
