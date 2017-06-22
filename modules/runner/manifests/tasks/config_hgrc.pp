# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Make sure runner runs at boot
class runner::tasks::config_hgrc($runlevel=0) {
    include runner
    include runner::settings

    # Since runner runs as builder_user on OS X and as root on Linux, but config_hgrc must
    # run as root, we need to use sudo on OS X.
    if $::operatingsystem == 'darwin' {
        include users::builder
        sudoers::custom {
            'config_hgrc-from-runner':
                user    => $users::builder::username,
                runas   => 'root',
                command => "${runner::settings::taskdir}/${runlevel}-config_hgrc";
        }
    }
}
