# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class disableservices::release_upgrader {
    case $::operatingsystem {
        Ubuntu: {
            case $::operatingsystemrelease {
                12.04,14.04: {
                    file {
                        # http://askubuntu.com/questions/515161/ubuntu-12-04-disable-release-notification-of-14-04-in-update-manager
                        '/etc/update-manager/release-upgrades':
                            content => "[DEFAULT]\nPrompt=never\n";
                    }
                }
                16.04: {
                    package {'ubuntu-release-upgrader-core' :
                        ensure => absent,
                    }
                }
                default: {
                    fail ("${::operatingsystemrelease} is not supported")
                }
            }
        }
        default: {
            notice("Don't know how to disable release ugprader on ${::operatingsystem}.")
        }
    }
}
