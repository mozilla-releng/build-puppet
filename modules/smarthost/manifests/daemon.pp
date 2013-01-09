# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class smarthost::daemon {
    service { "postfix":
        ensure => running,
        hasstatus => true,
        hasrestart => true,
        enable => true,
        require => Class["smarthost::setup"],
    }
}
