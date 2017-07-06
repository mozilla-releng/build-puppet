# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define packages::pkgmsi($msi, $package=$title, $private=false, $install_options=[]) {
    include dirs::installersource::puppetagain_pub_build_mozilla_org::msis
    $installersource_posix = 'c:/InstallerSource/puppetagain.pub.build.mozilla.org'
    $installersource_win = 'c:\InstallerSource\puppetagain.pub.build.mozilla.org'
    $p = $private ? {
        true  => '/private',
        false => ''
    }
    file {
            "${installersource_posix}/MSIs/${msi}":
                source  => "puppet:///repos${p}/MSIs/${msi}",
                require => Class['dirs::installersource::puppetagain_pub_build_mozilla_org::msis'],
    }
    package {
            $package:
                ensure   => installed,
                provider => windows,
                source   => "${installersource_win}\\MSIs\\${msi}",
                require  => File["${installersource_posix}/MSIs/${msi}"];
    }
}
