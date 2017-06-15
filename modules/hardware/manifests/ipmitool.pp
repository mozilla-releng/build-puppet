# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class hardware::ipmitool {
    anchor {
        'hardware::ipmitool::begin': ;
        'hardware::ipmitool::end': ;
    }

    # install ipmitool..
    Anchor['hardware::ipmitool::begin'] ->
    class {
        'packages::openipmi': ;
    } -> Anchor['hardware::ipmitool::end']

    # and the kernel modules to support it..
    if ($::kernel == 'Linux') {
        Anchor['hardware::ipmitool::begin'] ->
        kernelmodule {
            'ipmi_devintf': ;
        } -> Anchor['hardware::ipmitool::end']
    }
}
