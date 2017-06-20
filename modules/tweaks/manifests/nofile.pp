# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class tweaks::nofile {
    # This class sets the file descriptor limit correctly,
    # which is needed to link b2g

    case $::kernel {
        Linux: {
            file {
                # This should really be a template with the number of fds
                # that are desired
                '/etc/security/limits.d/90-nofile.conf':
                    owner  => root,
                    group  => root,
                    mode   => '0644',
                    source => 'puppet:///modules/tweaks/90-nofile.conf';
            }
        }
    }
}
