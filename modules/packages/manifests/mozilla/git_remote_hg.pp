# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::mozilla::git_remote_hg {
    realize(Packages::Yumrepo['git-remote-hg'])
    case $::operatingsystem {
        CentOS: {
            package {
                'git-remote-hg':
                    ensure => absent;
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}

