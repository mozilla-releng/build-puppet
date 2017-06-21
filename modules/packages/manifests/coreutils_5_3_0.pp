#This Source Code Form is subject to the terms of the Mozilla Public
#License, v. 2.0. If a copy of the MPL was not distributed with this
#file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::coreutils_5_3_0 {

    include dirs::installersource::puppetagain_pub_build_mozilla_org::exes

    file {
        'C:/installersource/puppetagain.pub.build.mozilla.org/EXEs/coreutils-5.3.0.exe':
            ensure  => file,
            source  => 'puppet:///repos/EXEs/coreutils-5.3.0.exe',
            require => Class['dirs::installersource::puppetagain_pub_build_mozilla_org::exes'];
    }
    exec {
        'install_coreutils':
            command => "C:\\installersource\\puppetagain.pub.build.mozilla.org\\EXEs\\coreutils-5.3.0.exe  /silent /norestart",
            creates => "C:\\Program Files\\GnuWin32\\uninstall",
            require => File['C:/installersource/puppetagain.pub.build.mozilla.org/EXEs/coreutils-5.3.0.exe'],
    }
}
