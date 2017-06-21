# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class nrpe::check::hplog {
    include nrpe::settings
    $plugins_dir = $nrpe::settings::plugins_dir

    nrpe::check {
        'check_hplog':
            cfg => "${plugins_dir}/check_hplog -t l";
    }

    nrpe::plugin {
        'check_hplog': ;
    }

    sudoers::custom {
        'check_hplog':
            user    => 'nagios',
            runas   => 'root',
            command => '/sbin/hplog';
    }
}
