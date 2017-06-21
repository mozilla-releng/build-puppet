# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class nrpe::check::open_tcp {
    include nrpe::settings
    $plugins_dir = $nrpe::settings::plugins_dir

    nrpe::check {
        'check_open_tcp':
            cfg => "${plugins_dir}/check_open_tcp -w \$ARG1\$ -c \$ARG2\$ -p \$ARG3\$";
    }

    nrpe::plugin {
        'check_open_tcp': ;
    }

    sudoers::custom {
        'check_open_tcp':
            user    => 'nagios',
            runas   => 'root',
            command => '/usr/sbin/lsof';
    }
}
