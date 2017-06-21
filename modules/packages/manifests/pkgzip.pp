# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define packages::pkgzip($target_dir,  $zip, $package=$title, $private=false) {
    include dirs::installersource::puppetagain_pub_build_mozilla_org::zips
    include packages::7z920
    $installersource_posix = 'c:/InstallerSource/puppetagain.pub.build.mozilla.org'
    $installersource_win = 'c:\InstallerSource\puppetagain.pub.build.mozilla.org'
    $quoted_7zip =  $::hardwaremodel ? {
        i686    => '"C:\Program Files\7-Zip\7z.exe"',
        default => '"C:\Program Files (x86)\7-Zip\7z.exe"',
    }
    $p = $private ? {
        true  => '/private',
        false => ''
    }
    file {
            "${installersource_posix}/ZIPs/${zip}":
                source  => "puppet:///repos${p}/ZIPs/${zip}",
                require => Class['dirs::installersource::puppetagain_pub_build_mozilla_org::zips'];
    }
    shared::execonce {
            $zip :
                command => "${quoted_7zip} x ${installersource_win}\\ZIPs\\${zip} -o${target_dir} -y",
                require => [File["${installersource_posix}/ZIPs/${zip}"],
                                Class['packages::7z920']
                                        ];
    }
}
