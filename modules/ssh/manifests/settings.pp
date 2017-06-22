# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class ssh::settings {
    # config files' paths are different per platform
    case $::operatingsystem {
        CentOS, Ubuntu: {
            $ssh_config           = '/etc/ssh/ssh_config'
            $sshd_config          = '/etc/ssh/sshd_config'
            $known_hosts          = '/etc/ssh/ssh_known_hosts'
            $notify_on_key_change = []
        }
        Darwin: {
            $ssh_config           = '/etc/ssh_config'
            $sshd_config          = '/etc/sshd_config'
            $known_hosts          = '/etc/ssh_known_hosts'
            $notify_on_key_change = []
        }
        Windows: {
            $known_hosts = 'C:/Program Files/KTS/known_hosts' # ignored anyway
            # this exec is defined by ssh::config
            $notify_on_key_change = [Exec['generate-kts-publickey-logon-ini']]
            $genkey_dir           = 'C:/Program Files/KTS/genkeys'
        }
        default: {
            fail("Don't know how to configure SSH on this platform:")
        }
    }
}
