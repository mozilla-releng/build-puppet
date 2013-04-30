# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::upx {
    anchor {
        'packages::upx::begin': ;
        'packages::upx::end': ;
    }

    case $::operatingsystem {
        Darwin: {
            Anchor['packages::upx::begin'] ->
            file {
                # this is a bare executable from the old releng-puppet
                #   -upx version 3.05
                # TODO: build this into a DMG using normal puppetagain packaging
                "/usr/local/bin/upx":
                    source => "puppet:///repos/DMGs/bare-executables/upx",
                    mode => '0755';
            } -> Anchor['packages::upx::end']
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
