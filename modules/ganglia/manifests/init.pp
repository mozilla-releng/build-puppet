# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class ganglia {
    include ::config

    case $::config::org {
        moco: {
            case $::operatingsystem {
                CentOS: {
                    package {
                        "ganglia-gmond":
                            ensure => absent;
                    }

                    file {
                        "/etc/ganglia/gmond.conf":
                            ensure => absent;
                    }
                }
            }
        }

        default: {
            # no ganglia, so don't install
        }
    }
}
