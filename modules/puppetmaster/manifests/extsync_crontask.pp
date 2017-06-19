# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define puppetmaster::extsync_crontask($generation_script, $ensure,
    $hour='*', $minute='*', $month='*', $monthday='*', $weekday='*') {
    include cron

    $cronfile   = "/etc/cron.d/extsync-${title}.cron"
    $cronscript = "/usr/local/sbin/extsync-${title}"

    case $ensure {
        present: {
            file {
                $cronfile:
                    content => "${minute} ${hour} ${monthday} ${month} ${weekday} root /bin/bash ${cronscript} 2>&1 | logger -t extsync_${title}\n";
                $cronscript:
                    content => template("${module_name}/extsync_crontask.sh.erb"),
                    mode    => '0755';
            }
        }
        absent: {
            file {
                [$cronfile, $cronscript]:
                    ensure => absent;
            }
        }
    }
}
