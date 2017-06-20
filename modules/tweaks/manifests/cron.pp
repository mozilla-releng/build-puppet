# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class tweaks::cron {
    case $::operatingsystem {
        Ubuntu: {
            file {
                [ '/etc/cron.weekly/apt-xapian-index', '/etc/cron.weekly/man-db',
                  '/etc/cron.daily/apache2', '/etc/cron.daily/apport', '/etc/cron.daily/apt',
                  '/etc/cron.daily/aptitude', '/etc/cron.daily/bsdmainutils', '/etc/cron.daily/man-db',
                  '/etc/cron.daily/mlocate', '/etc/cron.daily/popularity-contest', '/etc/cron.daily/standard',
                  '/etc/cron.daily/update-notifier-common']:
                    ensure => absent;
            }
        }
        default: {
            notice("Don't know how to tweak cron on ${::operatingsystem}.")
        }
    }
}
