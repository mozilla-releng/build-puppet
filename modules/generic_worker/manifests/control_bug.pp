# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This class is used to create and close bugs automatically 
class generic_worker::control_bug {

    $bugzilla_api_key = secret('roller_bugzilla_api_key')
    $logfile = ''
    $bugzilla_url = 'https://bugzilla.mozilla.org'

    file { '/usr/local/bin/bugs.sh':
        ensure  => present,
        content => template('generic_worker/bugs.sh.erb'),
        mode    => '0644',
        owner   => root,
        group   => wheel,
    }

    # set logfile for each OS
    case $::operatingsystem {
        Darwin: {
            $logfile = '/var/log/system.log'
        }
        Ubuntu: {
            $logfile = '/var/log/syslog'
        }
        CentOS: {
            $logfile = '/var/log/messages'
        }
    }

}