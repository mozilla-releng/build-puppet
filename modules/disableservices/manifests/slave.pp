# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class disableservices::slave inherits disableservices::common {
    # This class disables unnecessary services on the slave

    include disableservices::iptables
    include disableservices::displaymanager
    include disableservices::notification_daemon

    case $::operatingsystem {
        Ubuntu : {
            include disableservices::release_upgrader
        }
        Darwin : {
            case $::macosx_productversion_major {
                '10.7': {
                    service {
                        [
                            'org.clamav.clamd',
                            'org.clamav.freshclam-init',
                            'org.clamav.freshclam',
                        ]:
                            ensure => stopped,
                            enable => false,
                    }
                }
            }
        }
    }
}
