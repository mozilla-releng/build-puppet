# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define sudoers::customfile($content) {
    include sudoers
    include packages::sudo

    file {
        "/etc/sudoers.d/$title":
            require => Class['packages::sudo'],
            mode => "440",
            owner => $::users::root::username,
            group => $::users::root::group,
            ensure => file,
            content => $content;
    }
}

