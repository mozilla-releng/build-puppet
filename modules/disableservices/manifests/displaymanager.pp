# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class disableservices::displaymanager {
    # This class disables unnecessary login manager start

    case $::operatingsystem {
        Ubuntu: {
            file {
                # removing the following file disables display manager start
                '/etc/X11/default-display-manager':
                    ensure => absent,
                    force  => true;
            }
        }
        Windows, Darwin, CentOS: {
            # N/A
        }
        default: {
            fail("Cant disable DM on ${::operatingsystem}")
        }
    }
}

