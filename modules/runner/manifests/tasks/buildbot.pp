# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Make sure runner runs at boot
class runner::tasks::buildbot($runlevel=4) {
    include runner
    include buildslave::install

    $buildslave_cmd = '/tools/buildbot/bin/buildslave'
    $buildbot_python = '/tools/buildbot/bin/python'
    $runslave_py = '/usr/local/bin/runslave.py'

    case $::operatingsystem {
        'Darwin': {
            # On OSX we want to inherit our environment from the launchd agent
            # so leave su out
            $runslave_cmd = "${buildbot_python} ${runslave_py}"
        }

        default: {
            $runslave_cmd = "su - ${::config::builder_username} -c '${buildbot_python} ${runslave_py}'"
        }
    }

    runner::task {
        "${runlevel}-buildbot.py":
            require => [
                File['/usr/local/bin/runslave.py'],
                Class['buildslave::install']
            ],
            content  => template("${module_name}/tasks/buildbot.py.erb");
    }
}
