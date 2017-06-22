# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# settings for runner
class runner::settings {
    case $::operatingsystem {
        'CentOS', 'Ubuntu': {
            $runner_path = '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games'
        }
        'Darwin': {
            $runner_path = '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11'
        }
        'Windows': {
            include buildslave
            include buildslave::install
            include packages::mozilla::python27

            $runner_path     = "C:\\opt\\runner"
            $runner_env_path = "${path};${runner_path};C:\\mozilla-build\\buildbotve;${::packages::mozilla::python27::pythondir};C:\\mozilla-build\\msys\\mingw\\bin;C:\\mozilla-build\\msys\\bin;C:\\mozilla-build\\msys\\local\\bin;.:/usr/local/bin"
            $python          = $::packages::mozilla::python27::python
        }
        default: {
            fail("Unsupported OS ${::operatingsystem}")
        }
    }
    case $::operatingsystem {
        'Windows': {
            $root = "C:\\opt\\runner"
        }
        default: {
            $root = '/opt/runner'
        }
    }
    $taskdir   = "${root}/tasks.d"
    $configdir = "${root}/config.d"
}
