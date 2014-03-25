# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define aws_manager::crontask($ensure, $virtualenv_dir, $user, $cwd, $params='',
                             $hour='*', $minute='*', $month='*', $monthday='*',
                             $weekday='*', $subject=$title) {
    include cron
    include ::config

    $cronfile = "/etc/cron.d/aws_manager-$title.cron"
    $cronscript = "${virtualenv_dir}/bin/aws_manager-$title.sh"
    $lockdir = "${virtualenv_dir}"

    case $ensure {
        present: {
            file {
                $cronfile:
                    content => "$minute $hour $monthday $month $weekday $user $cronscript | mail -E -s '[aws cron] $subject' ${::config::aws_manager_mail_to}\n";
                $cronscript:
                    content => template("${module_name}/crontask.erb"),
                    mode => 0755;
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
