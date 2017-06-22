# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define rsyslog::config ($file = $title, $contents = '', $need_mysql=false) {
    include rsyslog
    include packages::rsyslog

    if ($need_mysql) {
        include packages::rsyslog_mysql
    }

    case $::operatingsystem {
        CentOS,Ubuntu: {
            include rsyslog::settings

            if ($file != undef) and ($contents != undef) {
                file {
                    "/etc/rsyslog.d/${file}.conf":
                        notify    => Service['rsyslog'],
                        mode      => $rsyslog::settings::mode,
                        owner     => $rsyslog::settings::owner,
                        group     => $rsyslog::settings::group,
                        content   => $contents,
                        # rsyslog configs can contain passwords..
                        show_diff => false;
                }
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
