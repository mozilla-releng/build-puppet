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
            Anchor['packages::mozilla::git::begin'] ->
            package {
                "mozilla-git":
                    ensure => '2.4.1-3.el6';
            } -> Anchor['packages::mozilla::git::end']
        }
        Darwin: {
            Anchor['packages::mozilla::git::begin'] ->
            packages::pkgdmg {
                git:
                    version => "1.7.9.4-1";
            } -> Anchor['packages::mozilla::git::end']
        }
        Windows: {
            file {
                "C:/installersource/puppetagain.pub.build.mozilla.org/EXEs/Git-1.9.2-preview20140411.exe":
                    ensure  => file,
                    source  => "puppet:///repos/EXEs/Git-1.9.2-preview20140411.exe",
                    require => Class["dirs::installersource::puppetagain_pub_build_mozilla_org::exes"];
            }
            exec {
                "Git-1.9.2-preview20140411.exe":
                    command => "C:\\installersource\\puppetagain.pub.build.mozilla.org\\EXEs\\Git-1.9.2-preview20140411.exe /VERYSILENT /DIR=C:\\mozilla-build\\Git",
                    creates => "C:\\mozilla-build\\git\\unins000.exe",
                    require => File["C:/installersource/puppetagain.pub.build.mozilla.org/EXEs/Git-1.9.2-preview20140411.exe"],
            }
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
