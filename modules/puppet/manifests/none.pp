# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class puppet::none {
    include ::config
    include dirs::usr::local::bin

    # create a service
    case $::operatingsystem {
        CentOS: {
            service {
                "puppet":
                    # disable the service
                    enable => false;
            }
            file {
                "/etc/cron.d/puppetcheck.cron":
                    ensure => absent;
            }
        }
        Ubuntu: {
            file {
                "/etc/puppet/init":
                    ensure => absent;
                "/etc/init.d/puppet":
                    ensure => absent;
            }
        }

        Darwin: {
            file {
                "/Library/LaunchDaemons/com.mozilla.puppet.plist":
                    ensure => absent;
                "/usr/local/bin/run-puppet.sh":
                    ensure => absent;
            }
        }
        default: {
            fail("puppet::none support missing for $::operatingsystem")
        }
    }
}

