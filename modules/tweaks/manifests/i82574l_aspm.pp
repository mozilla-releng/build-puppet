# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Disable ASPM, a PCI power-saving mechanism, for this particluar vendor/model
# pair, since it doesn't work.  See bug 808397.

class tweaks::i82574l_aspm {
    case $::kernel {
        Linux: {
            # the idea here is to disable ASPM L0s and L1 on the NICs.  For these
            # particular devices, that register is at the offset below.  This is
            # unlikely to work on other hardware (and likely to make things go boom)!
            exec {
                'setpci-aspm-off':
                    command => '/sbin/setpci -d 8086:10d3 CAP_EXP+10.b=40',
                    unless  => '/usr/bin/test -z "`/sbin/setpci -d 8086:10d3 CAP_EXP+10.b | grep -v ^40$`"';
            }
        }
        default: {
            notice("Don't know how to disable ASPM on ${::kernel}")
        }
    }
}


