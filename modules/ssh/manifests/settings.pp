# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class ssh::settings {
    # config files' paths are different per platform
    case $::operatingsystem {
        CentOS, Ubuntu: {
            $ssh_config = "/etc/ssh/ssh_config"
            $sshd_config = "/etc/ssh/sshd_config"
        }
        Darwin: {
            $ssh_config = "/etc/ssh_config"
            $sshd_config = "/etc/sshd_config"
        }
        default: {
            fail("Don't know how to configure SSH on this platform")
        }
    }
}
