# Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Win 7 SDK original source: https://www.microsoft.com/en-us/download/details.aspx?id=18950
# The original file is an ISO. The ISO was mounted and compressed into a zip file, so it can be deployed, extracted and needed parts installed

class packages::win7sdk {
    packages::pkgzip {
        'win7sdk_zip':
            zip        => 'win7sdk.zip',
            private    => true,
            target_dir => '"c:\InstallerSource\puppetagain.pub.build.mozilla.org\zips\win7sdk"';
    }
    exec {
        '7sdk_setup_exe':
            command     => "C:\\installersource\\puppetagain.pub.build.mozilla.org\\ZIPs\\win7sdk\\GRMSDK_EN_DVD\\setup.exe /quiet /params:ADDLOCAL=ALL",
            subscribe   => Packages::Pkgzip['win7sdk_zip'],
            refreshonly => true;
    }
    package {
        'Microsoft Windows Performance Toolkit':
            ensure          => installed,
            source          => 'C:\Program Files\Microsoft SDKs\Windows\v7.1\Redist\Windows Performance Toolkit\wpt_x86.msi',
            install_options => [{'MSI_TARGETDIR' => "C:\\perftools\\"}, {'WPFPERFDIR' => 'C:\perftools\WPF Performance Suite'}, {'ARPINSTALLLOCATION' => 'C:\perftools'}, {'ADDLOCAL' => 'ALL'}],
            require         => Exec['7sdk_setup_exe'];
    }
    # No need to keep files around
    # No concerns of re-installs because of the semaphore in the puppetagain directory the for the pkgzip package
    file {
        'C:/installersource/puppetagain.pub.build.mozilla.org/ZIPs/win7sdk':
            ensure  => absent,
            purge   => true,
            recurse => true,
            force   => true,
            require => Package['Microsoft Windows Performance Toolkit'];
    }
}
