# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Support for dashes in class and defined type names differs depending on the release of Puppet you’re running. 
# To ensure compatibility on all versions, you should avoid using dashes.
class dirs::slave::talos_data {
    include dirs::slave

    case $::operatingsystem {
        windows: {
            file {
                'c:/slave/talos-data' :
                    ensure => directory,
            }
        }
        default: {
            fail('No C:/slave dir on this platform')
        }
    }
}
