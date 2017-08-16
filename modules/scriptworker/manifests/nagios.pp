# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define scriptworker::nagios(
    $username,
) {
    include nrpe::settings
    $plugins_dir = $nrpe::settings::plugins_dir

    nrpe::check {
        'check_pending_scriptworker_tasks':
            cfg => "sudo ${plugins_dir}/check_pending_scriptworker_tasks -w \$ARG1\$ -c \$ARG2\$";
        'check_scriptworker_file_age':
            cfg => "sudo -u ${username} ${plugins_dir}/check_file_age -w \$ARG1\$ -c \$ARG2\$ -f '\$ARG3\$'";
        'check_scriptworker_file_age_ok_if_missing':
            cfg => "sudo -u ${username} ${plugins_dir}/check_file_age -m -w \$ARG1\$ -c \$ARG2\$ -f '\$ARG3\$'";
    }

    file {
        "${plugins_dir}/check_pending_scriptworker_tasks":
            ensure  => present,
            mode    => '0755',
            require => Class['nrpe::base'],
            content => template('scriptworker/check_pending_scriptworker_tasks.erb');
    }

    nrpe::plugin {
        'check_file_age': ;
    }

    sudoers::custom {
        'check_pending_scriptworker_tasks':
            user    => 'nagios',
            runas   => 'root',
            command => "${plugins_dir}/check_pending_scriptworker_tasks";
        'check_file_age':
            user    => 'nagios',
            runas   => $username,
            command => "${plugins_dir}/check_file_age";
    }
}
