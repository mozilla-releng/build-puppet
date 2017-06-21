# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class fw::roles::puppetmaster_from_all_releng {
    include fw::networks

    fw::rules { 'allow_puppetmaster_http':
        sources =>  $::fw::networks::all_releng,
        app     => 'http'
    }
    fw::rules { 'allow_puppetmaster_https':
        sources =>  $::fw::networks::all_releng,
        app     => 'https'
    }
    fw::rules { 'allow_puppetmaster_puppet':
        sources =>  $::fw::networks::all_releng,
        app     => 'puppet'
    }
}
