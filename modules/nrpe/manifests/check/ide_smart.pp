# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class nrpe::check::ide_smart {
    include nrpe::settings
    $plugins_dir = $nrpe::settings::plugins_dir

    nrpe::check {
        'check_ide_smart':
            cfg => "sudo ${plugins_dir}/check_ide_smart -n -d \$ARG1\$";
    }

    sudoers::custom {
        'check_ide_smart':
            user    => 'nagios',
            runas   => 'root',
            command => "${plugins_dir}/check_ide_smart";
    }
}
