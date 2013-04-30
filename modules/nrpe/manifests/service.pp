# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class nrpe::service {
    include packages::nrpe

    case $::operatingsystem {
        CentOS, Ubuntu: {
            service {
                "nrpe":
                    enable => "true",
                    ensure => "running",
                    require => Class['packages::nrpe'];
            }
        }
        Darwin: {
            service {
                "org.nagios.nrpe":
                    enable => "true",
                    ensure => "running",
                    require => Class['packages::nrpe'];
            }
        }
        default: {
            fail("Don't know how to enable nrpe on $::operatingsystem")
        }
    }
}
