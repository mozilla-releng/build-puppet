# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define bors::install($basedir, $owner, $group, $version) {
    include packages::mozilla::python27

    python::virtualenv {
        $basedir:
            python   => $::packages::mozilla::python27::python,
            require  => Class['packages::mozilla::python27'],
            user     => $owner,
            group    => $group,
            packages => [
                "bors==${version}",
            ];
    }
}
