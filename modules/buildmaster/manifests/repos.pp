# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# buildmaster repo class
# creates the souce code repoitories
define buildmaster::repos($hg_repo, $dst_dir, $branch="default") {
    include packages::mozilla::py27_mercurial
    include users::builder

    exec {
        # make will take care of checking out
        # buildbotcustom and tools
        "clone-${dst_dir}":
            require => [
                Class['packages::mozilla::py27_mercurial'],
            ],
            command => "${::packages::mozilla::py27_mercurial::mercurial} clone -b ${branch} ${hg_repo} ${dst_dir}",
            creates => "${dst_dir}",
            user => "${users::builder::username}";
    }
}
