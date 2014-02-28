# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class diamond::settings {
    $servicename = "diamond"
    # config files' paths are different per platform
    case $::operatingsystem {
        CentOS: {
            $diamond_config = "/etc/diamond/diamond.conf"
        }
        default: {
            fail("Don't know how to configure Diamond on this platform")
        }
    }
}
