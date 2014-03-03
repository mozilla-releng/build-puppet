# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class diamond::service {
    include diamond::settings

    case $::operatingsystem {
        CentOS : {
            service {
                $diamond::settings::servicename:
                    enable => "true",
                    ensure => "running";
            }
        }
        default: {
            fail("Don't know how to configure Diamond on this platform")
        }
    }
}
