# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This installs the system git, which is basically whatever version that
# OS provides.

class packages::system_git {
    anchor {
        'packages::system_git::begin': ;
        'packages::system_git::end': ;
    }

    case $::operatingsystem {
        CentOS, Ubuntu: {
            Anchor['packages::system_git::begin'] ->
            package {
                'git':
                    ensure => latest;
            } -> Anchor['packages::system_git::end']
        }
        default: {
            # on Darwin, this comes with XCode, but by default there is no git installed.
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
