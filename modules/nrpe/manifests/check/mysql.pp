# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class nrpe::check::mysql {
    include nrpe::settings
    $plugins_dir = $nrpe::settings::plugins_dir

    $hostname = secret('buildbot_schedulerdb_hostname')
    $username = secret('buildbot_schedulerdb_username')
    $password = secret('buildbot_schedulerdb_password')
    nrpe::check {
        'check_mysql':
            cfg => "${plugins_dir}/check_mysql -H ${hostname} -u ${username} -p ${password}";
    }
}
