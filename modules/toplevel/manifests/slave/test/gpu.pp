# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class toplevel::slave::test::gpu inherits toplevel::slave::test {
    class {
        gui:
            on_gpu => true;
    }

    case $::hardwaremodel {
        # We only run Android x86 test jobs on
        # the 64-bit gpu host machines
        "x86_64": {
            include packages::cpu-checker
            include packages::qemu-kvm
            include packages::bridge-utils
            include androidemulator
        }
    }
}
