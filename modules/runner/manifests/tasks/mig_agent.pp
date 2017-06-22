# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Cleanup
class runner::tasks::mig_agent($runlevel=1) {
    include runner

    # Since runner runs as builder_user on OS X and as root on Linux, but mig must
    # run as root, we need to use sudo on OS X.
    if $::operatingsystem == 'darwin' {
        include users::builder
        sudoers::custom {
            'mig-agent-from-runner':
                user    => $users::builder::username,
                runas   => 'root',
                command => '/usr/local/bin/mig-agent';
        }

    }

    runner::task {
        "${runlevel}-mig_agent":
            source  => 'puppet:///modules/runner/mig_agent_checkin.sh';
    }
}
