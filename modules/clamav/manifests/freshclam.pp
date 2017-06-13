# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class clamav::freshclam {
    include packages::clamd

    file {
        '/etc/freshclam.conf':
            source => "puppet:///modules/${module_name}/freshclam.conf";
        '/etc/init.d/freshclam':
            mode   => '0755',
            source => "puppet:///modules/${module_name}/freshclam.init";
    }
    exec {
        # Run freshclam after clamd is installed to refresh the initial database
        '/usr/bin/freshclam':
            refreshonly => true,
            require     => File['/etc/freshclam.conf'],
            subscribe   => Class['packages::clamd'];
    }
    service {
        'freshclam':
            require => File['/etc/init.d/freshclam'],
            enable  => true;
    }
}
