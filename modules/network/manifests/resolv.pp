# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class network::resolv {
    include ::config

    # always set the search order to the domain
    case $::operatingsystem {
        CentOS,Ubuntu: {
            augeas {
                'resolvconf':
                    context => '/files/etc/resolv.conf',
                    changes => template("${module_name}/resolv.conf.augeas.erb");
            }
        }
        Darwin: {
            # OS X has its own brand of crazy broken DNS, which seems to play nice with DHCP.
            # Better left untouched.
        }
        Windows: {
            # Same here, so far
        }
    }
}

