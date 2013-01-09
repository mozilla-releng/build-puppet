# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# XXX Hacks to work around the fact we don't yet have private DNS working
class network::aws {
    host {
        "repos":
            ensure => present,
            ip => $serverip;
        "puppet":
            ensure => present,
            ip => $serverip;
    }
}
