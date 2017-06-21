# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mod_passenger {
    case $::operatingsystem {
        CentOS: {
            # BE CAREFUL!  Updating this without immediately restarting Apache
            # can cause 404's for puppet file URLs, which can cause recursive
            # file{..} resources to suddenly delete everything.
            package {
                'mod_passenger':
                    ensure => '3.0.12-1.el6';
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
