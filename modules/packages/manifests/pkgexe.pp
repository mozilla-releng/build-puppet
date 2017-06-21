#This Source Code Form is subject to the terms of the Mozilla Public
#License, v. 2.0. If a copy of the MPL was not distributed with this
#file, You can obtain one at http://mozilla.org/MPL/2.0/.

define packages::pkgexe( $exe, $package=$title, $private=false, $install_options=[]) {
    include dirs::installersource::puppetagain_pub_build_mozilla_org::exes
    $installersource_posix = 'c:/InstallerSource/puppetagain.pub.build.mozilla.org'
    $installersource_win   = 'c:\InstallerSource\puppetagain.pub.build.mozilla.org'
    $p = $private ? {
        true  => '/private',
        false => ''
    }
    file {
            "${installersource_posix}/EXEs/${exe}":
                source  => "puppet:///repos${p}/EXEs/${exe}",
                require => Class['dirs::installersource::puppetagain_pub_build_mozilla_org::exes'];
    }
    package {
            $package:
                ensure   => installed,
                provider => windows,
                source   => "${installersource_win}\\EXEs\\${exe}",
                require  => File["${installersource_posix}/EXEs/${exe}"];
    }
}
