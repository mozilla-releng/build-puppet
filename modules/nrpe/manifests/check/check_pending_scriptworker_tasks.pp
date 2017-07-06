# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class nrpe::check::check_pending_scriptworker_tasks {
    include nrpe::settings
    $plugins_dir = $nrpe::settings::plugins_dir

    nrpe::check {
        'check_pending_scriptworker_tasks':
            cfg => "sudo ${plugins_dir}/check_pending_scriptworker_tasks -w \$ARG1\$ -c \$ARG2\$";
    }

    nrpe::plugin {
        'check_pending_scriptworker_tasks.erb': ;
    }

    sudoers::custom {
        'check_pending_scriptworker_tasks':
            user    => 'nagios',
            runas   => 'root',
            command => "${plugins_dir}/check_pending_scriptworker_tasks";
    }
}

