# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Mozilla build package(s) source: https://ftp.mozilla.org/pub/mozilla.org/mozilla/libraries/win32/

class packages::mozilla::mozilla_build {
    include dirs::installersource::puppetagain_pub_build_mozilla_org::exes

    $version = "1.11.0"
    $moz_bld_dir = "C:\\mozilla-build"

    # Bat file to check the for the current version and delete the version file and buildbot virtual environment directories if there is a mismatch.
    # This will allow for the MozillaBuildSetup package install, and the package install will retrigger virtual environment creations.
    file {
        "C:/etc/MozBld_ver_check.bat":
            content => template("${module_name}/MozBld_ver_check.bat.erb");
    }
    exec {
        "check_version":
            command => 'C:\Windows\system32\cmd.exe /c C:\etc\MozBld_ver_check.bat',
            require => File["C:/etc/MozBld_ver_check.bat"];
    }
    file {
        "C:/installersource/puppetagain.pub.build.mozilla.org/EXEs/MozillaBuildSetup-$version.exe":
            ensure  => file,
            source  => "puppet:///repos$p/EXEs/MozillaBuildSetup-$version.exe",
            require => Class["dirs::installersource::puppetagain_pub_build_mozilla_org::exes"];
    }
    # Install Mozilla-Build package as needed
    exec {
        "MozillaBuildSetup-$version":
            command => "C:\\installersource\\puppetagain.pub.build.mozilla.org\\EXEs\\MozillaBuildSetup-$version.exe /S", 
            creates => "$moz_bld_dir\\version",
            require => [Exec ["check_version"],
                            File["C:/installersource/puppetagain.pub.build.mozilla.org/EXEs/MozillaBuildSetup-$version.exe"]
                       ];
    }
    # Update hg's Path.rc to point to a valid path
    file {
        "$moz_bld_dir/hg/hgrc.d/Paths.rc":
            replace => true,
            source  => "puppet:///modules/packages/Paths.rc",
            require => Exec["MozillaBuildSetup-$version"];
    }
    # Exec is being used here since the file link attribute throws errors on subsequent runs on Windows
    exec {
        "pyhton_27_link":
            command => "C:\\mozilla-build\\msys\\bin\\ln.exe -s $moz_bld_dir\\python $moz_bld_dir\\python27",
            creates => "$moz_bld_dir\\python27",
            require => Exec["MozillaBuildSetup-$version"];
    }
    # Append needed directories to the Windows path variable
    windows_path {
        $moz_bld_dir:
            ensure => present;
    }
    windows_path {
        "$moz_bld_dir\\python":
            ensure => present;
    }
    windows_path {
        "$moz_bld_dir\\python\scripts":
            ensure => present;
    }
    windows_path {
        "$moz_bld_dir\\msys\\bin":
            ensure => present;
    }
    windows_path {
        "$moz_bld_dir\\vim\\vim72":
            ensure => present;
    }
    windows_path {
        "$moz_bld_dir\\wget":
            ensure => present;
    }
    windows_path {
        "$moz_bld_dir\\info-zip":
            ensure => present;
    }
}
