# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class puppet::periodic {
    include puppet
    include config
    include puppet::puppetize_sh
    include puppet::renew_cert
    include dirs::usr::local::bin

    case $::operatingsystem {
        CentOS,Ubuntu: {
            $minute1 = fqdn_rand(30)
            $minute2 = $minute1+30
            file {
                # This is done via crontab due to a memory leak in puppet identified by
                # Mozilla IT.  There is enough splay here to avoid killing the master
                # (configured in the crontask).  Note that files in /etc/cron.d must not
                # have a '.' in the filename
                '/etc/cron.d/puppetcheck':
                    content => template('puppet/puppetcheck.cron.erb');
                '/etc/cron.d/puppetcheck.cron':
                    ensure => absent;
            }
        }
        Darwin: {
            # Launchd substitutes for crond on Darwin.  This runs a shell snippet
            # which adds some splay so that we don't kill the master every half-hour
            $svc_plist = '/Library/LaunchDaemons/com.mozilla.puppet.plist'
            file {
                $svc_plist:
                    owner  => root,
                    group  => wheel,
                    mode   => '0644',
                    source => 'puppet:///modules/puppet/puppet-periodic.plist';
                '/usr/local/bin/run-puppet.sh':
                    ensure => absent;
            }
            service {
                'com.mozilla.puppet':
                    ensure  => 'running',
                    enable  => true,
                    require => File[$svc_plist];
            }
        }
        default: {
            fail("puppet::periodic support missing for ${::operatingsystem}")
        }
    }
}
