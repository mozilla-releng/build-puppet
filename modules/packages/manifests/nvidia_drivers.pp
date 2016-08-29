# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::nvidia_drivers {
    include needs_reboot

    case $::operatingsystem {
        Ubuntu: {
            $nvidia_version = "361"
            $nvidia_full_version = "361.42"
            # The Ubuntu graphics-drivers repo embeds the version number in the
            # package name, so we can easily require "latest"
            realize(Packages::Aptrepo['graphics-drivers'])
            package {
                "nvidia-$nvidia_version":
                    ensure => latest,
                    require => Class['packages::kernel'],
                    # the nvidia drivers need to be loaded, which usually
                    # requires unloading the nouveau drivers, which are
                    # installed by default for the startup frame buffer.. so we
                    # need to reboot.
                    notify => Exec['reboot_semaphore'];
                ['nvidia-310', 'nvidia-settings-310']:
                    ensure => absent,
                    notify => Exec['reboot_semaphore'];
            }
            file {
                "/etc/init/nvidia-$nvidia_version.conf":
                    notify  => Exec['reboot_semaphore'],
                    require => Package["nvidia-$nvidia_version"],
                    mode    => 0755,
                    content => template("${module_name}/nvidia_dkms.conf.erb");
            }
        }

        Windows: {
            # This should serve as the basic frame work for the nvidia driver install on testers in the datacenter and AWS
            # However, the install has only been tested on Win 7 in AWS
            # Further testing will be needed in the other environments

            $datacnter_domain = "wintest.releng.scl3.mozilla.com"
            $nv_dir           = "C:\\installersource\\puppetagain.pub.build.mozilla.org\\ZIPs\\nvidia\\"

            $arch = $hardwaremodel ? {
                i686    => "32bit",
                default => "64bit",
            }
            # The default domain should cover testers in use1 and usw2
            $nv_version = $domain ? {
                "$datacnter_domain" => "314.07",
                default             => "354.42",
            }
            $nv_name = $domain ? {
                "$datacnter_domain" => "-desktop-win8-win7-winvista-",
                default             => "-quadro-grid-desktop-notebook-win8-win7-",
            }
            $lang = $domain ? {
                "$datacnter_domain" => "-english-whql",
                default             => "-international-whql",
            }
            # The installation for 314 and 354 exits with 1 even though the driver is installed and functioning
            # The exit code is due to a dll file failing to be unloaded
            # Leaving the variables in place so there is work around in the future if this condition changes
            # 0 and 1 is being left in place because there maybe a condition under USERDATA where it exits with 0
            $ex_code = $domain ? {
                "$datacnter_domain" => "1",
                default             => "0, 1,",
            }

            $nv_driver = "$nv_version$nv_name$arch$lang"

            packages::pkgzip {
                "nv_driver":
                    zip        => "$nv_driver.zip",
                    private    => true,
                    target_dir => "c:\\InstallerSource\\puppetagain.pub.build.mozilla.org\\zips\\nvidia";
           }
           # This will fail on any AWS instance type that is not g2
           exec {
                "nvidia_setup_exe":
                    command     => "$nv_dir$nv_driver\\setup.exe /s -clean -noreboot -loglevel:6 -log:C:\\ProgramData\\PuppetLabs\\puppet\\var\\log",
                    returns     => "$ex_code",
                    subscribe   => Packages::Pkgzip["nv_driver"],
                    refreshonly => true;
           }
           # No need to keep these files around
           file {
                "C:/installersource/puppetagain.pub.build.mozilla.org/ZIPs/nvidia-$nvidia_full_version-${arch}bit":
                    ensure  => absent,
                    purge   => true,
                    recurse => true,
                    force   => true,
                    require => Exec["nvidia_setup_exe"];
           }
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
