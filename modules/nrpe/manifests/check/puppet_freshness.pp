# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class nrpe::check::puppet_freshness {
    include nrpe::settings
    $plugins_dir = $nrpe::settings::plugins_dir

    nrpe::check {
        'check_puppet_freshness':
            cfg => "sudo ${plugins_dir}/check_puppet_freshness -t \$ARG1\$";
    }

    nrpe::plugin {
        'check_puppet_freshness': ;
    }

    sudoers::custom {
        'check_puppet_freshness':
            user    => 'nagios',
            runas   => 'root',
            command => "${plugins_dir}/check_puppet_freshness";
    }
}
