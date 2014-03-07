# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::nodejs {
    case $::operatingsystem {
        Ubuntu: {
            package {
                # This package is a recompiled version of
                # https://launchpad.net/~chris-lea/+archive/node.js/+packages
                "nodejs":
                    ensure => '0.10.21-1chl1~precise1';
                # and it includes node.1.gz which conflicts with nodejs-legacy,
                # despite not including /usr/bin/node
                "nodejs-legacy":
                    ensure => absent,
                    before => Package['nodejs'];
            }
            file {
                "/usr/bin/node":
                    ensure => link,
                    target => "/usr/bin/nodejs";
            }
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
