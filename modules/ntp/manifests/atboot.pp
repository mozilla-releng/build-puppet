# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class ntp::atboot {
    include config

    $ntpservers = $config::ntp_servers 

    case $::operatingsystem {
        CentOS, Darwin: {
            include packages::ntp
            service {
                "ntpdate":
                    enable => true,
                    hasstatus => false;
            }
        }
        Ubuntu: {
            include config
            include packages::ntpdate
            # ntpdate is run by if-up
            file {
                "/etc/default/ntpdate":
                    content => template("ntp/ntpdate.default.erb");
            }
        }
        default: {
            fail("cannot instantiate on $::operatingsystem")
        }
    }
}
