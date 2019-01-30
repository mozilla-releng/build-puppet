# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class hardware::apple_firmware {

    if $::operatingsystem == 'Darwin' {
        # Add if conditions for each hardware model explicitly supported
        # then add the list of acceptable firmware version for that supported model
        if $::sp_machine_model == 'Macmini7,1' and !($::sp_boot_rom_version in ['MM71.0232.B00']) {
            fail("Boot ROM version ${::sp_boot_rom_version} does not match an acceptable version for hardware model ${::sp_machine_model}")
        }
    }
}
