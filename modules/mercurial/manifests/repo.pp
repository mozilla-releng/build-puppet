# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define mercurial::repo($hg_repo, $dst_dir, $user, $branch="default") {
    include packages::mozilla::py27_mercurial

    exec {
        "clone-${dst_dir}":
            require => Class['packages::mozilla::py27_mercurial'],
            command => "${::packages::mozilla::py27_mercurial::mercurial} clone -b ${branch} ${hg_repo} ${dst_dir}",
            creates => "${dst_dir}",
            user => $user;
    }
}
