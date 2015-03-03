# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# settings for runner
class runner::settings {
    case $::operatingsystem {
        'CentOS', 'Ubuntu': {
            $runner_path = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games"
        }
        'Darwin': {
            $runner_path = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11"
        }
        default: {
            fail("Unsupported OS ${::operatingsystem}")
        }
    }
    $root = '/opt/runner'
    $taskdir = "${root}/tasks.d"
    $configdir = "${root}/config.d"
    $task_hook = "${root}/task_hook.py"
    $influxcreds = "${root}/.influxcreds"
}
