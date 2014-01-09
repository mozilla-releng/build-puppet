# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class shellprofile::settings {

    $profile_d = $::operatingsystem ? {
        Windows => 'c:/windows/profile.d',
        default => '/etc/profile.d',
    }
    $profile_puppet_d = $::operatingsystem ? {
        Windows => 'c:/windows/profile.puppet.d',
        default => '/etc/profile.puppet.d',
    }
}
