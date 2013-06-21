# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class puppet::puppetize_sh {
    include users::root
    file {
        "${users::root::home}/puppetize.sh":
            source => "puppet:///modules/puppet/puppetize.sh",
            owner => root,
            group => $users::root::group,
            mode => 0755;
    }

    file {
        # temporary - see bug 883558
        "${users::root::home}/puppetize.log":
            ensure => absent;
    }
}
