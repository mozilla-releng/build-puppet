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
    if ($::operatingsystem != Windows) {
        include mercurial::system_hgrc
    }

    case $::operatingsystem {
        CentOS: {
            $mercurial = "/tools/python27-mercurial/bin/hg"
            realize(Packages::Yumrepo['mozilla-mercurial'])
            Anchor['packages::mozilla::py27_mercurial::begin'] ->
            package {
                "mozilla-python27-mercurial":
                    ensure => '3.7.3-1.el6',
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
            file {
                "/var/db/.puppet_pkgdmg_installed_python27-mercurial-3.2.1-1.dmg":
                    ensure => absent;
            }
            Anchor['packages::mozilla::py27_mercurial::begin'] ->
            packages::pkgdmg {
                python27-mercurial:
                    version => "3.2.1-1";
            } -> Anchor['packages::mozilla::py27_mercurial::end']
        }
        Windows: {
            include packages::mozilla::mozilla_build
            $mercurial = 'C:\mozilla-build\hg\hg.exe'
            $merc_exe = $hardwaremodel ? {
                i686    => "Mercurial-3.2.1.exe",
                default => "Mercurial-3.2.1-x64.exe",
            }
            $merc_exe_dir = "C:\\installersource\\puppetagain.pub.build.mozilla.org\\EXEs\\"
            $merc_exe_flag = " /SILENT /DIR=C:\\mozilla-build\\hg"
            $quoted_merc_cmd = "\"$merc_exe_dir$merc_exe$merc_exe_flag\""

            Anchor['packages::mozilla::py27_mercurial::begin'] ->
            # This is a temporary work around until we have Windows package management in place 
            # Ref Bugs 1178487 & 1170588 for the reasons behind Mercurial-3.2.1 being handled this manner
            file { "C:/installersource/puppetagain.pub.build.mozilla.org/EXEs/$merc_exe" :
                ensure => file,
                source => "puppet:///repos/EXEs/$merc_exe",
            } -> exec { "Schtasks_Mercurial-3.2.1":
                command  => "C:\\Windows\\system32\\schtasks.exe /ru SYSTEM /create /sc once /st 23:59  /tn hg_3-2-1 /tr $quoted_merc_cmd",
                require  => Exec["remove_old_hg"],
                creates  => "C:\\mozilla-build\\hg\\MPR.dll",
            } -> exec { "Install_Mercurial-3.2.1":
                command  => '"C:\Windows\system32\schtasks.exe" /run /tn hg_3-2-1',
                subscribe => Exec["Schtasks_Mercurial-3.2.1"],
                refreshonly => true,
            } -> exec { "RM_Schtasks_Mercurial-3.2.1":
                command  => '"C:\Windows\system32\schtasks.exe" /delete /tn hg_3-2-1 /f',
                subscribe => Exec["Install_Mercurial-3.2.1"],
                refreshonly => true,
            } -> Anchor['packages::mozilla::py27_mercurial::end']
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
