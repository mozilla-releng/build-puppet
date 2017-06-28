# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class duo::duo_unix (
    $enabled           = false,
    $ikey              = '',
    $skey              = '',
    $host              = '',
    $group             = '',
    $http_proxy        = '',
    $fallback_local_ip = 'no',
    $failmode          = 'safe',
    $pushinfo          = 'no',
    $autopush          = 'no',
    $prompts           = '3',
    $accept_env_factor = 'no',
) {
    if $enabled {
        # Sanity Check
        if $ikey == '' or $skey == '' or $host == '' {
            fail('ikey, skey, and host must all be defined.')
        }

        # Install OpenSSH 6.2+
        include packages::openssh
    }

    # Do not leave duo config around if disabled
    $conf_present = $enabled ? {
        true => 'present',
        default => 'absent',
    }

    include ssh
    include packages::duo_unix

    file { '/etc/duo/pam_duo.conf':
        ensure    => $conf_present,
        owner     => 'root',
        group     => 'root',
        mode      => '0600',
        show_diff => false,
        content   => template('duo/duo.conf.erb'),
        require   => Class['packages::duo_unix'];
    }

    class { 'duo::pam':
        enabled => $enabled,
    }
}
