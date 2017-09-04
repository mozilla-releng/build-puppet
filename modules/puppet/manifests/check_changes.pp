# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# puppet::check_changes
#
# Check puppet changes on jumphosts and sent email notification to relops group

class puppet::check_changes {

    # The file where we will store the output for puppet agent -t --noop command. This output will be sent to the email body
    $logfile = '/tmp/puppet.txt'

    case $::operatingsystem {
        # On jumphosts we have only CentOS
        CentOS: {
            $hour = 7
            file {
                '/usr/local/bin/puppetcheck_changes.sh':
                    content => template('puppet/puppetcheck_changes.sh.erb'),
                    mode    => '0755';
                '/etc/cron.d/puppetcheckchanges':
                    content => template('puppet/puppetcheck_changes.cron.erb');
            }
        }
        default: {
            fail("puppet::check_changes support missing for ${::operatingsystem}")
        }
    }
}