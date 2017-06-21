#This Source Code Form is subject to the terms of the Mozilla Public
#License, v. 2.0. If a copy of the MPL was not distributed with this
#file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::netframework_3_5 {

    include dirs::installersource::puppetagain_pub_build_mozilla_org::exes

    file {
        'C:/installersource/puppetagain.pub.build.mozilla.org/EXEs/dotNetFx35setup.exe':
            ensure  => file,
            source  => 'puppet:///repos/EXEs/dotNetFx35setup.exe',
            require => Class['dirs::installersource::puppetagain_pub_build_mozilla_org::exes'];
    }
    exec {
        'install_framework-3_5':
            command => 'C:\installersource\puppetagain.pub.build.mozilla.org\EXEs\dotNetFx35setup.exe  /silent /norestart',
            creates => 'C:\Windows\Microsoft.NET\Framework\v3.5\Microsoft.Build.Tasks.v3.5.dll',
            require => File['C:/installersource/puppetagain.pub.build.mozilla.org/EXEs/dotNetFx35setup.exe'],
    }
}
