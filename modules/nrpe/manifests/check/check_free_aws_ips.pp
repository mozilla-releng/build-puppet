# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class nrpe::check::check_free_aws_ips {
    include nrpe::settings
    $plugins_dir = $nrpe::settings::plugins_dir

    nrpe::check {
        'check_free_aws_ips':
            cfg => "${plugins_dir}/check_free_aws_ips";
    }

    nrpe::plugin {
        'check_free_aws_ips': ;
    }

    sudoers::custom {
        'check_open_tcp':
            user    => 'nagios',
            runas   => 'buildduty',
            command => '/builds/aws_manager/bin/python /builds/aws_manager/cloud-tools/scripts/aws_check_subnets.py -r us-east-1 -r us-west-2 -s test -s try -s build'
    }
}
