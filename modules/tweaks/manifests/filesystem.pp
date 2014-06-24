# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class tweaks::filesystem {
    # Optimize EXT4 writeback performance on virtual machines only
    if ($::virtual =~ /xen/) {
        case $::operatingsystem {
            CentOS: {
                sysctl::value {
                    'vm.dirty_writeback_centisecs':
                        value => 6000;
                    'vm.dirty_expire_centisecs':
                        value => 6000;
                    'vm.dirty_ratio':
                        value => 40;
                    'vm.dirty_background_ratio':
                        value => 1;
                }
            }
        }
    }
}

