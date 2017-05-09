# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class nrpe::check::signing_file_ages {
    include nrpe::settings
    $plugins_dir = $nrpe::settings::plugins_dir

    nrpe::check {
        'check_signing_file_age':
            cfg => "sudo -u cltsign $plugins_dir/check_file_age -w \$ARG1\$ -c \$ARG2\$ -f '\$ARG3\$'";
        'check_signing_file_age_ok_if_missing':
            cfg => "sudo -u cltsign $plugins_dir/check_file_age -m -w \$ARG1\$ -c \$ARG2\$ -f '\$ARG3\$'";
    }

    nrpe::plugin {
        "check_file_age": ;
    }

    sudoers::custom {
        'check_file_age':
            user => 'nagios',
            runas => 'cltsign',
            command => "$plugins_dir/check_file_age";
    }
}
