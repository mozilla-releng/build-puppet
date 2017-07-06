# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class duo::pam (
    $enabled = false,
) {

    include ssh
    include ssh::service

    $pam_module  = $::architecture ? {
        i386   => '/lib/security/pam_duo.so',
        i686   => '/lib/security/pam_duo.so',
        x86_64 => '/lib64/security/pam_duo.so'
    }

    $p = '/files/etc/pam.d/sshd'
    $aug_match = "${p}/*/module[. = '${pam_module}']"


    # If duo is disabled, we do that by resetting pam.d/sshd
    if $enabled {
        augeas { 'Enable Duo PAM Configuration' :
            changes => [
                # auth  required pam_env.so
                "set ${p}/2/type auth",
                "set ${p}/2/control required",
                "set ${p}/2/module pam_env.so",
                # auth  sufficient pam_duo.so
                "ins 100 after ${p}/2",
                "set ${p}/100/type auth",
                "set ${p}/100/control sufficient",
                "set ${p}/100/module ${pam_module}",
                # auth  required pam_deny.so
                "ins 101 after ${p}/100",
                "set ${p}/101/type auth",
                "set ${p}/101/control required",
                "set ${p}/101/module pam_deny.so",
            ],
            onlyif  => "match ${aug_match} size == 0",
            notify  => Class['ssh::service'],
        }
    } else {
        augeas { 'Disable Duo PAM Configuration' :
            changes => [
                # auth include password-auth
                "set ${p}/2/type auth",
                "set ${p}/2/control include",
                "set ${p}/2/module password-auth",
                "rm ${p}/3",
                "rm ${p}/4",
            ],
            onlyif  => "match ${aug_match} size != 0",
            notify  => Class['ssh::service'],
        }
    }
}
