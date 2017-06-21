# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mozilla::py27_virtualenv {
    $virtualenv = '/tools/python27-virtualenv/bin/virtualenv'
    anchor {
        'packages::mozilla::py27_virtualenv::begin': ;
        'packages::mozilla::py27_virtualenv::end': ;
    }

    include packages::mozilla::python27

    case $::operatingsystem {
        CentOS: {
            Anchor['packages::mozilla::py27_virtualenv::begin'] ->
            package {
                'mozilla-python27-virtualenv':
                    ensure  => '1.7.1.2-2.el6',
                    require => Class['packages::mozilla::python27'];
            } -> Anchor['packages::mozilla::py27_virtualenv::end']
        }
        Darwin: {
            Anchor['packages::mozilla::py27_virtualenv::begin'] ->
            packages::pkgdmg {
                'python27-virtualenv':
                    os_version_specific => false,
                    version             => '1.7.1.2-1';
            } -> Anchor['packages::mozilla::py27_virtualenv::end']
        }
        Windows: {
            #TODO: add windows support https://bugzilla.mozilla.org/show_bug.cgi?id=1113324
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
