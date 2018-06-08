# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mergeday::install {
    include ::config
    include users::buildduty
    include packages::gcc
    include packages::make
    include packages::mercurial
    include packages::mysql_devel
    include packages::mozilla::git
    include packages::mozilla::python27
    include packages::mozilla::python3
    include packages::mozilla::py27_virtualenv
    include packages::mozilla::py27_mercurial
    include packages::patchutils

    python::virtualenv {
        "/home/buildduty/mergeday":
            python          => $::packages::mozilla::python27::python,
            rebuild_trigger => Class["packages::mozilla::python27"],
            require         => [
                Class["packages::mozilla::python27"],
            ],
            user            => $users::buildduty::username,
            group           => $users::buildduty::group,
            packages        => file("mergeday/requirements.txt");
    }
}
