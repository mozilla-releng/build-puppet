# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::yasm {
    anchor {
        'packages::yasm::begin': ;
        'packages::yasm::end': ;
    }

    case $::operatingsystem {
        Darwin: {
            Anchor['packages::yasm::begin'] ->
            packages::pkgdmg {
                'yasm':
                    version => '1.3.0';
            } -> Anchor['packages::yasm::end']
        }
        Windows: {
            include packages::mozilla::mozilla_build
            file {
                'C:/mozilla-build/yasm/yasm.exe':
                    ensure  => file,
                    source  => 'puppet:///repos/EXEs/yasm-1.3.0-win64.exe',
                    require => Exec['remove_old_yasm'],
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
