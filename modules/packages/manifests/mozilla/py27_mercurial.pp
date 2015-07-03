# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mozilla::py27_mercurial {


    anchor {
        'packages::mozilla::py27_mercurial::begin': ;
        'packages::mozilla::py27_mercurial::end': ;
    }

    include packages::mozilla::python27
    include mercurial::ext::bundleclone
    include mercurial::system_hgrc

    case $::operatingsystem {
        CentOS: {
            $mercurial = "/tools/python27-mercurial/bin/hg"
            Anchor['packages::mozilla::py27_mercurial::begin'] ->
            package {
                "mozilla-python27-mercurial":
                    ensure => '3.2.1-1.el6',
                    require => Class['packages::mozilla::python27'];
            } -> Anchor['packages::mozilla::py27_mercurial::end']
        }
        Ubuntu: {
            $mercurial = "/tools/python27-mercurial/bin/hg"
            realize(Packages::Aptrepo['mozilla-mercurial'])
            Anchor['packages::mozilla::py27_mercurial::begin'] ->
            package {
                "mozilla-python27-mercurial":
                    ensure => '3.2.1',
                    require => Class['packages::mozilla::python27'];
            } -> Anchor['packages::mozilla::py27_mercurial::end']

            # Some things want to find hg in /usr/bin, so symlink
            # but only if its not present from another package
            file {
                "/usr/bin/hg":
                    ensure => "link",
                    replace => "no",
                    mode => 755, # if the binary is here, the symlink won't care
                    target => $mercurial;
            }
        }
        Darwin: {
            $mercurial = "/tools/python27-mercurial/bin/hg"
            Anchor['packages::mozilla::py27_mercurial::begin'] ->
            packages::pkgdmg {
                python27-mercurial:
                    version => "3.2.1-1";
            } -> Anchor['packages::mozilla::py27_mercurial::end']
        }
        Windows: {
            $mercurial = 'C:\mozilla-build\hg\hg.exe'
            include packages::mozilla::mozilla_build
            Anchor['packages::mozilla::py27_mercurial::begin'] ->
            file { "C:/installersource/puppetagain.pub.build.mozilla.org/EXEs/Mercurial-3.2.1-x64.exe" :
                ensure => file,
                source => "puppet:///repos/EXEs/Mercurial-3.2.1-x64.exe",
            } -> exec { "Mercurial-3.2.1":
                command   => "C:\\installersource\\puppetagain.pub.build.mozilla.org\\EXEs\\Mercurial-3.2.1-x64.exe /VerySilent /SUPPRESSMSGBOXES /DIR=C:\\mozilla-build\\hg",
                subscribe => Exec["remove_old_hg"],
                creates   => "C:\\mozilla-build\\hg\\MPR.dll", 
            } -> Anchor['packages::mozilla::py27_mercurial::end']
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
