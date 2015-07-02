# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mercurial::system_hgrc {
    include mercurial::settings
    file {
        $mercurial::settings::hgrc_parentdirs:
            ensure => directory,
            owner => "root",
            group => "root";
    }

    mercurial::hgrc {
        "$mercurial::settings::hgrc":
            owner => "root",
            group => "root";
    }
}
