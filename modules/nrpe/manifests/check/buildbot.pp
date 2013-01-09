# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class nrpe::check::buildbot {
    include nrpe::settings
    $plugins_dir = $nrpe::settings::plugins_dir

    nrpe::check {
        'check_buildbot':
            # check_procs sees slightly different things on *BSD (OS X)
            cfg => $::operatingsystem ? {
                CentOS => "$plugins_dir/check_procs -w 1:1 -C twistd --argument-array=buildbot.tac",
                Darwin => "$plugins_dir/check_procs -w 1:1 -C python --argument-array=buildbot.tac",
            };
    }
}
