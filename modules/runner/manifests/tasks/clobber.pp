# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Take care of all pending clobbers
class runner::tasks::clobber($runlevel=3) {
    include runner

    case $::operatingsystem {
        'Windows': {
            include packages::mozilla::mozilla_build
            runner::task {
                "${runlevel}-clobberer.bat":
                    content  => template("${module_name}/tasks/clobber.bat.erb");
            }
            # Clobberer.py is needed before it is checkout for use by the clobber.bat
            exec {
                'get_clobberer.py' :
                    command => "C:\\mozilla-build\\wget\\wget.exe  https://hg.mozilla.org/build/tools/raw-file/default/clobberer/clobberer.py",
                    cwd     => "C:\\opt",
                    creates => "C:\\opt\\clobberer.py",
                    require => Class["packages::mozilla::mozilla_build"];
            }
        }
        default: {
            runner::task {
                "${runlevel}-clobber":
                    content => template("${module_name}/tasks/clobber.erb");
            }
        }
    }
}
