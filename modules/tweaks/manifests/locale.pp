# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Set up locale settings
class tweaks::locale {
    case $::operatingsystem {
        Ubuntu: {
            file {
                '/var/lib/locales/supported.d/local':
                    content => "en_US UTF-8\n",
                    notify  => Exec['generate-locales'];
                '/etc/default/locale':
                    source  => 'puppet:///modules/tweaks/locale.ubuntu';
            }
            exec {
                'generate-locales':
                    command     => '/usr/sbin/dpkg-reconfigure --frontend=noninteractive locales',
                    refreshonly => true;
            }
        }
        CentOS: {
            file {
                '/etc/sysconfig/i18n':
                    source => 'puppet:///modules/tweaks/locale.centos';
            }
        }
        Darwin: {
            # OS X doesn't need any changes
        }
        default: {
            notice("Don't know how to set up locale on ${::operatingsystem}.")
        }
    }
}
