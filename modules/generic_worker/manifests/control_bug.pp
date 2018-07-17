# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This class provides a utility to the worker, 
# to enable it to raise a Bugzilla bug against itself, if it considers that it is in a bad state.
class generic_worker::control_bug {

    include ::users::root
    include ::users::builder

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

    file { '/usr/local/share/generic-worker':
        ensure => directory,
        owner  => $users::root::username,
        group  => $users::root::group
    }

    file { '/usr/local/share/generic-worker/bugzilla-utils.sh':
        ensure  => present,
        content => template('generic_worker/bugzilla-utils.sh.erb'),
        mode    => '0755',
        owner   => $users::root::username,
        group   => $users::root::group,
    }
}
