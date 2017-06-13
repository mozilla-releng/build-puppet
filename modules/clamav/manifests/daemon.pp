# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class clamav::daemon {
    include packages::clamd

    service {
        'clamd':
            ensure  => running,
            require => Class['packages::clamd'],
            enable  => true;
    }
}
