# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Make sure runner runs at boot
class runner::tasks::purge_builds($runlevel=1, $required_space=10) {
    # Requires tools checked out
    include runner
    if ($::operatingsystem != Windows) {
        include runner::tasks::checkout_tools
    }

    case $::operatingsystem {
        'Windows': {
            include packages::mozilla::mozilla_build
            runner::task {
                "${runlevel}-purge_builds.bat":
                    content  => template("${module_name}/tasks/purge_builds.bat.erb");
            }
            exec {
                'get_purge_builds.py' :
                    command => "C:\\mozilla-build\\wget\\wget.exe  https://hg.mozilla.org/build/tools/raw-file/default/buildfarm/maintenance/purge_builds.py",
                    cwd     => "C:\\opt\\runner",
                    creates => "C:\\opt\\runner\\purge_builds.py",
                    require => Class['packages::mozilla::mozilla_build'];
            }
        }
        default: {
            runner::task {
                "${runlevel}-purge_builds":
                    content  => template("${module_name}/tasks/purge_builds.erb");
            }
        }
    }
}
