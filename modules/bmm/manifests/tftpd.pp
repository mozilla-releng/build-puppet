# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class bmm::tftpd {
    include ::tftpd

    file {
        "/var/lib/tftpboot/pxelinux.cfg":
            ensure => directory,
            # owned by apache so the CGI can write to it
            owner => apache,
            group => apache;
        "/var/lib/tftpboot/panda-live":
            ensure => directory;
        "/var/lib/tftpboot/panda-live/uImage":
            ensure => file,
            source => "puppet:///bmm/pxe/uImage",
            show_diff => false;
        "/var/lib/tftpboot/panda-live/uInitrd":
            ensure => file,
            source => "puppet:///bmm/pxe/uInitrd",
            show_diff => false;
    }
}
