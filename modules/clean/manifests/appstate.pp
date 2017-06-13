# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class clean::appstate {
    # clean out saved application state on OS X, and prevent new state from being written
    # two different ways
    if ($::operatingsystem == 'Darwin') {
        include users::builder

        tidy {
            "${::users::builder::home}/Library/Saved Application State":
                matches => '*.savedState',
                rmdirs  => true,
                recurse => true;
        }
        file {
            "${::users::builder::home}/Library":
                ensure  => directory,
                owner   => $::users::builder::username,
                group   => $::users::builder::group,
                mode    => '0700',
                require => Class['users::builder'];
            "${::users::builder::home}/Library/Preferences":
                ensure  => directory,
                owner   => $::users::builder::username,
                group   => $::users::builder::group,
                mode    => '0700',
                require => Class['users::builder'];
            "${::users::builder::home}/Library/Saved Application State":
                ensure => directory,
                owner  => $::users::builder::username,
                group  => $::users::builder::group,
                mode   => '0500'; # remove write permission
        }
        osxutils::defaults {
            # set the user preference to not save app states
            'builder-NSQuitAlwaysKeepsWindows':
                domain  => "${::users::builder::home}/Library/Preferences/.GlobalPreferences.plist",
                key     => 'NSQuitAlwaysKeepsWindows',
                value   => '0',
                require => Class['users::builder'];
        }
    }
}
