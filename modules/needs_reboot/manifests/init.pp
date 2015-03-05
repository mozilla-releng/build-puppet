# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class needs_reboot {
    include needs_reboot::motd

    exec {
        # ask the puppet startup script to reboot
        "reboot-semaphore":
            command => $::operatingsystem ? {
                windows => "type nul > C:/REBOOT_AFTER_PUPPET",
                default => "touch /REBOOT_AFTER_PUPPET",
            },
            path => ['/bin/', '/usr/bin/'],
            refreshonly => true;
    }
    # if the needs_reboot fact exists ensure the semaphore exists 
    if $needs_reboot {
        file { '/REBOOT_AFTER_PUPPET':
            ensure => file;
        }
    }
}
