# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class smarthost::daemon {
    case $::operatingsystem {
        CentOS, Ubuntu: {
            service {
                'postfix':
                    ensure     => running,
                    hasstatus  => true,
                    hasrestart => true,
                    enable     => true,
                    require    => Class['smarthost::setup'],
            }
        }

        Darwin: {
            # this is built-in, but for good measure:
            service {
                'org.postfix.master':
                    ensure => running,
                    enable => true;
            }
        }
        default: {
            fail("Don't know how to run the smarthost service on ${::operatingsystem}")
        }
    }
}
