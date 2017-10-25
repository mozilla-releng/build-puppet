# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mozilla::git {
    anchor {
        'packages::mozilla::git::begin': ;
        'packages::mozilla::git::end': ;
    }

    case $::operatingsystem {
        CentOS: {
            realize(Packages::Yumrepo['git'])
            Anchor['packages::mozilla::git::begin'] ->
            package {
                'git':
                    ensure => '2.7.6-moz1.el6';
                'perl-Git':
                    ensure => '2.7.6-moz1.el6';
                'perl-Error':
                    ensure => present;
                'mozilla-git':
                    ensure => absent;
            } -> Anchor['packages::mozilla::git::end']
        }
        Ubuntu: {
            case $::operatingsystemrelease {
                12.04: {
                    realize(Packages::Aptrepo['git'])
                    Anchor['packages::mozilla::git::begin'] ->
                    package {
                        'git':
                            ensure => '1:2.7.4-0ppa1~ubuntu12.04.1';
                    } -> Anchor['packages::mozilla::git::end']
                }
                14.04: {
                    realize(Packages::Aptrepo['git'])
                    Anchor['packages::mozilla::git::begin'] ->
                    package {
                        'git':
                            ensure => '1:2.7.4-0ppa1~ubuntu14.04.1';
                    } -> Anchor['packages::mozilla::git::end']
                }
                16.04: {
                    Anchor['packages::mozilla::git::begin'] ->
                    package {
                        'git':
                            ensure => '1:2.7.4-0ubuntu1';
                    } -> Anchor['packages::mozilla::git::end']
                }
                default: {
                    fail("Unrecognized Ubuntu version ${::operatingsystemrelease}")
                }
            }
        }
        Darwin: {
            case $::macosx_productversion_major {
                10.10: {
                    Anchor['packages::mozilla::git::begin'] ->
                    packages::pkgdmg {
                        'git':
                            os_version_specific => true,
                            private             => false,
                            version             => '2.14.1-1';
                    } -> Anchor['packages::mozilla::git::end']
                }
                10.7: {
                    # New release # needed for 10.7 in order to push new package
                    # This is due to pkgdmg package resource being non-versionable
                    # See bug 1257633
                    Anchor['packages::mozilla::git::begin'] ->
                    packages::pkgdmg {
                        'git':
                            os_version_specific => true,
                            private             => false,
                            version             => '2.14.1-1';
                    } -> Anchor['packages::mozilla::git::end']
                }
                default: {
                    fail("Cannot install on OS X ${::macosx_productversion_major}")
                }
            }
        }
        Windows: {

            include dirs::etc

            $git_exe  = 'Git-2.7.4-32-bit.exe'
            $inst_dir = "C:\\installersource\\puppetagain.pub.build.mozilla.org\\EXEs\\"
            $inst_cmd = "${inst_dir}${git_exe}"

            file {
                "C:/installersource/puppetagain.pub.build.mozilla.org/EXEs/${git_exe}":
                    ensure  => file,
                    source  => "puppet:///repos/EXEs/${git_exe}",
                    require => Class['dirs::installersource::puppetagain_pub_build_mozilla_org::exes'];
            }
            exec {
                $git_exe:
                    command => "${inst_cmd}  /VERYSILENT /DIR=C:\\mozilla-build\\Git",
                    creates => 'C:\mozilla-build\git\unins001.exe',
                    require => File["C:/installersource/puppetagain.pub.build.mozilla.org/EXEs/${git_exe}"],
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
