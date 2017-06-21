# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::postfix {
    case $::operatingsystem {
        Ubuntu: {
            package {
                'postfix':
                    ensure => latest;
            }
        }
        CentOS: {
            # on CentOS, ssmtp and postfix both satisfy the same virtual, but
            # ssmtp tends to get pulled in for other things like cronie or
            # nagios-plugins.  Unfortunately, that means we can't uninstall
            # ssmtp cleanly before installing postfix with the regular puppet
            # `package` provider.  So we use a little bit of 'yum shell' to
            # switch out ssmtp and postfix in a single transaction, if ssmtp is
            # installed.  It's possible to have both installed at once, with
            # an alternates invocation to point things in the right direction,
            # but it's safer to just ensure ssmtp is not installed.

            file {
                '/root/switch-ssmtp-postfix':
                    content => "erase ssmtp\ninstall postfix\nrun\n";
            } ->
            exec {
                'switch-ssmtp-postfix':
                    onlyif  => '/bin/rpm -qi ssmtp',
                    command => '/usr/bin/yum -y shell < /root/switch-ssmtp-postfix';
            } ~>
            exec {
                'update-mta-alternatives':
                    command     => '/usr/sbin/alternatives --auto mta',
                    refreshonly => true;
            }

            # let Puppet take care of updating
            package {
                'postfix':
                    ensure => latest;
            }
        }

        Darwin: {
            # Postfix ships with OS X
        }

        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
