# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Make sure runner runs at boot
class runner::tasks::buildbot($runlevel=4) {
    include runner
    include buildslave::install

    $buildslave_cmd = '/tools/buildbot/bin/buildslave'
    $buildbot_python = '/tools/buildbot/bin/python'
    $runslave_py = $::operatingsystem ? {
        Windows => 'C:/programdata/puppetagain/runslave.py',
        default => '/usr/local/bin/runslave.py',
    }
    case $::operatingsystem {
        'Darwin': {
            # On OSX we want to inherit our environment from the launchd agent
            # so leave su out
            $runslave_cmd = "${buildbot_python} ${runslave_py}"
        }
        'Windows': {
            # Windows is still a little difficult to get right regarding the environment
            # as such, for the time being, a separate buildbot batch file is used
            # to start buildbot on that platform
            runner::task {
                "${runlevel}-buildbot.bat":
                    require => Class['buildslave::install'],
                    source  => 'puppet:///modules/runner/tasks/buildbot.bat';
            }
        }
        default: {
            $runslave_cmd = "su - ${::config::builder_username} -c '${buildbot_python} ${runslave_py}'"
        }
    }
    runner::task {
        "${runlevel}-buildbot.py":
            require => [
                File[$runslave_py],
                Class['buildslave::install']
            ],
            content => template("${module_name}/tasks/buildbot.py.erb");
    }
}
