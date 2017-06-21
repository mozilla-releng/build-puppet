# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::wget {
    anchor {
        'packages::wget::begin': ;
        'packages::wget::end': ;
    }

    case $::operatingsystem {
        CentOS: {
            Anchor['packages::wget::begin'] ->
            package {
                'wget':
                    ensure => '1.15-2.el6';  # hand-compiled; see .spec
            } -> Anchor['packages::wget::end']
        }
        Ubuntu: {
            case $::operatingsystemrelease {
                12.04: {
                    Anchor['packages::wget::begin'] ->
                    package {
                        'wget':
                            ensure => '1.13.4-2ubuntu1';
                    } -> Anchor['packages::wget::end']
                }
                16.04: {
                    Anchor['packages::wget::begin'] ->
                    package {
                        'wget':
                            ensure => '1.17.1-1ubuntu1.1';
                    } -> Anchor['packages::wget::end']
                }
                default: {
                    fail("Ubuntu ${::operatingsystemrelease} is not supported")
                }
            }
        }
        Darwin: {
            Anchor['packages::wget::begin'] ->
            packages::pkgdmg {
                'wget':
                    version => '1.15-2';
            } -> Anchor['packages::wget::end']
        }
        Windows: {
            # on Windows, we use the wget that ships with MozillaBuild
            include packages::mozilla::mozilla_build
            Anchor['packages::wget::begin'] ->
            Class['packages::mozilla::mozilla_build'] ->
            packages::pkgzip {
                'wget-1.16.3-win32.zip':
                    zip        => 'wget-1.16.3-win32.zip',
                    target_dir => "${packages::mozilla::mozilla_build::moz_bld_dir}/wget",
                    subscribe  => Exec["MozillaBuildSetup-${packages::mozilla::mozilla_build::version}"];
            } ->
            file {
                "${packages::mozilla::mozilla_build::moz_bld_dir}/msys/etc/ca-bundle.crt":
                    ensure    => file,
                    source    => 'puppet:///modules/packages/wget/ca-bundle.crt',
                    subscribe => Exec["MozillaBuildSetup-${packages::mozilla::mozilla_build::version}"];
            }
            -> Anchor['packages::wget::end']
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
