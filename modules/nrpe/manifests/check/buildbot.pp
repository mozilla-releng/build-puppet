# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class nrpe::check::buildbot {
    include nrpe::settings
    $plugins_dir = $nrpe::settings::plugins_dir

    nrpe::check {
        'check_buildbot':
            # we just look for buildbot.tac, which is always in the command
            # line.  Different OS's show different things for the command name
            # (twistd, python, python2.7, etc.), so don't use -C
            cfg          => "${plugins_dir}/check_procs -w 1:1 --argument-array=buildbot.tac",
            nsclient_cfg => 'check_buildbot=inject CheckProcState ShowAll python.exe=started';
    }
}
