# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class nrpe::check::hpasm {
    include nrpe::settings
    $plugins_dir = $nrpe::settings::plugins_dir

    nrpe::check {
        'check_hpasm':
            cfg => "${plugins_dir}/check_hpasm -t 20";
    }

    nrpe::plugin {
        'check_hpasm': ;
    }

    sudoers::custom {
        'check_hpasm':
            user    => 'nagios',
            runas   => 'root',
            command => '/sbin/hpasmcli';
    }
}
