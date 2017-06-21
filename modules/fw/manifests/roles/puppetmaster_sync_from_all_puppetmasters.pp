# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class fw::roles::puppetmaster_sync_from_all_puppetmasters {
    include fw::networks

    fw::rules { 'allow_puppetmaster_sync':
        sources => [ $::fw::networks::non_distingushed_puppetmasters,
                    $::fw::networks::distingushed_puppetmaster ],
        app     => 'ssh'
    }
}
