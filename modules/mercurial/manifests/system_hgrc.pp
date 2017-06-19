# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mercurial::system_hgrc {
    include mercurial::settings
    include mercurial::cacert

    $group = $::operatingsystem ? {
        Darwin  => wheel,
        Windows => undef,
        default => root
    }
    $owner =  $::operatingsystem ? {
        Windows => undef,
        default => root
    }

    file {
        $mercurial::settings::hgrc_parentdirs:
            ensure => directory,
            owner  => $owner,
            group  => $group;
    }

    mercurial::hgrc {
        $mercurial::settings::hgrc:
            owner => $owner,
            group => $group;
    }
}
