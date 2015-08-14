# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::nvidia_drivers {
    include needs_reboot

    realize(Packages::Aptrepo['xorg-edgers'])

    # The Ubuntu xorg-edgers reqo embeds the version number in the package
    # name, so we can easily require "latest"

    $nvidia_version = "310"

    case $::operatingsystem {
        Ubuntu: {
            package {
                "nvidia-$nvidia_version":
                    ensure => latest,
                    require => Class['packages::kernel'],
                    # the nvidia drivers need to be loaded, which usually
                    # requires unloading the nouveau drivers, which are
                    # installed by default for the startup frame buffer.. so we
                    # need to reboot.
                    notify => Exec['reboot_semaphore']
            }
        }

        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
