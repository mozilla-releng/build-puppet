# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define git::repo($repo, $dst_dir, $user) {
    include packages::mozilla::git

    exec {
        "git-clone-${dst_dir}":
            require => Class['packages::mozilla::git'],
            command => "git clone ${repo} ${dst_dir}",
            creates => "${dst_dir}/.git",
            path    => '/usr/local/bin:/usr/bin:/bin',
            cwd     => '/',
            user    => $user;
    }
}
