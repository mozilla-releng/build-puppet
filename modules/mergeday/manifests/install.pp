# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mergeday::install {
    include ::config
    include users::buildduty
    include packages::mercurial
    include packages::mozilla::python27
    include packages::mozilla::py27_virtualenv
    include packages::mozilla::py27_mercurial
    include packages::patch

    python::virtualenv {
        "/home/buildduty/mergeday":
            python          => $::packages::mozilla::python27::python,
            rebuild_trigger => Class["packages::mozilla::python27"],
            require         => [
                Class["packages::mozilla::python27"],
                Class["users::buildduty"],
            ],
            user            => $users::buildduty::username,
            group           => $users::buildduty::group,
            packages        => file("mergeday/requirements.txt");
    }

    file {
        "${users::buildduty::home}/.ssh/stage-ffxbld-merge-key":
            mode      => '0600',
            owner     => $users::buildduty::username,
            group     => $users::buildduty::group,
            show_diff => false,
            content   => secret('ssh_key_stage-ffxbld-merge');
        "${users::buildduty::home}/.ssh/ffxbld-merge-key":
            mode      => '0600',
            owner     => $users::buildduty::username,
            group     => $users::buildduty::group,
            show_diff => false,
            content   => secret('ssh_key_ffxbld-merge');
    }
}
