# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class fw::roles::nightly_signing_from_linux {
    include fw::networks

    fw::rules { 'allow_nightly_signing_from_linux':
        # All sources sans dep signing workers
        sources =>  [   $::fw::networks::all_signing_linux_workers,
                        $::fw::networks::dev_signing_linux_workers ],
        app     => 'nightly_signing'
    }
}
