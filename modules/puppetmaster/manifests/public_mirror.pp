# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class puppetmaster::public_mirror {
    include puppetmaster::settings
    include packages::xinetd
    include packages::rsync

    # http mirror
    if ($::puppetmaster::settings::is_public_mirror) {
        httpd::config {
            "public_mirror.conf":
                content => template("puppetmaster/public_mirror.conf.erb");
        }
    } else {
        httpd::config {
            "public_mirror.conf":
                ensure => absent;
        }
    }

    # rsync mirror
    case $::operatingsystem {
        CentOS: {
            if ($::puppetmaster::settings::is_public_mirror) {
                file {
                    "/etc/rsyncd.conf":
                        content => template("${module_name}/rsyncd.conf.erb");
                    "/etc/xinetd.d/rsync":
                        content => template("${module_name}/rsyncd_xinetd.conf.erb"),
                        notify => Service['xinetd'];
                }
                service {
                    'xinetd':
                        ensure => running,
                        enable => true,
                        require => Class['packages::xinetd'];
                }
            } else {
                file {
                    "/etc/rsyncd.conf":
                        ensure => absent;
                    "/etc/xinetd.d/rsync":
                        ensure => absent,
                        notify => Service['xinetd'];
                }
                service {
                    'xinetd':
                        ensure => stopped,
                        enable => false,
                        require => Class['packages::xinetd'];
                }
            }
        }
    }
}
