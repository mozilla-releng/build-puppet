# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define aws_manager::crontask($ensure, $virtualenv_dir, $user, $cwd, $params='',
            $hour='*', $minute='*', $month='*', $monthday='*',
            $weekday='*', $script=$title, $subject=$title,
            $process_timeout=0) {
    include cron
    include ::config

    $cronfile              = "/etc/cron.d/aws_manager-${title}.cron"
    $cronscript            = "${virtualenv_dir}/bin/aws_manager-${title}.sh"
    $lockdir               = $virtualenv_dir
    $monitoring_cronfile   = "/etc/cron.d/aws_manager-${title}-monitor.cron"
    $monitoring_cronscript = "${virtualenv_dir}/bin/aws_manager-${title}-monitor.sh"

    case $ensure {
        present: {
            file {
                $cronfile:
                    content => "${minute} ${hour} ${monthday} ${month} ${weekday} ${user} ${cronscript} 2>&1 | logger -t '${subject}'\n";
                $cronscript:
                    content => template("${module_name}/crontask.erb"),
                    mode    => '0755';
            }
            if ($process_timeout > 0){
                file {
                    $monitoring_cronfile:
                        content => "${minute} ${hour} ${monthday} ${month} ${weekday} ${user} ${monitoring_cronscript} 2>&1 | logger -t '${subject}-monitor'\n";
                    $monitoring_cronscript:
                        content => template("${module_name}/kill_long_running.sh.erb"),
                        mode    => '0755';
                }
            }
        }
        absent: {
            file {
                [$cronfile, $cronscript, $monitoring_cronfile, $monitoring_cronscript]:
                    ensure => absent;
            }
        }
    }
}
