# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class fw::roles::dep_signing_from_osx {
    include fw::networks

    fw::rules { 'allow_dep_signing_from_osx':
        # All signing sources
        sources =>  [   $::fw::networks::all_signing_linux_workers,
                        $::fw::networks::dev_signing_linux_workers,
                        $::fw::networks::all_dep_signing_workers ],
        app     => 'dep_signing'
    }
}
