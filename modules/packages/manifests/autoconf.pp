# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::autoconf {
    anchor {
        'packages::autoconf::begin': ;
        'packages::autoconf::end': ;
    }

    case $::operatingsystem {
        Darwin: {
            Anchor['packages::autoconf::begin'] ->
            packages::pkgdmg {
                autoconf:
                    # this DMG came from the old releng puppet.  Its provenance is unknown.
                    version => "2.13";
            } -> # install package before the symlink

            # apparently l10n uses 'autoconf-2.13' instead of 'autoconf213'
            file {
                "/usr/local/bin/autoconf-2.13":
                    ensure => link,
                    target => "/usr/local/bin/autoconf213";
            } -> Anchor['packages::autoconf::end']
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
