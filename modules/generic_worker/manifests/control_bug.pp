# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This class is used to create and close bugs automatically 
class generic_worker::control_bug {

    $bugzilla_api_key = secret('roller_bugzilla_api_key!prod')
    $bugzilla_url = 'https://bugzilla.mozilla.org'

    # set logfile for each OS
    case $::operatingsystem {
        Darwin: {
            $log_file = '/var/log/system.log'
        }
        Ubuntu: {
            $log_file = '/var/log/syslog'
        }
        CentOS: {
            $log_file = '/var/log/messages'
        }
    }

    file { '/usr/local/share/generic-worker/bugzilla-utils.sh':
        ensure  => present,
        content => template('generic_worker/bugzilla-utils.sh.erb'),
        mode    => '0755',
        owner   => root,
        group   => wheel,
    }
}
