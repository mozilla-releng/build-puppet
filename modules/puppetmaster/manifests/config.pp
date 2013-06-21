# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class puppetmaster::config {
    include packages::httpd
    include ::config

    file {
        "/etc/puppet/fileserver.conf":
            mode => 0644,
            owner => root,
            group => root,
            require => Class["puppet"],
            source => "puppet:///modules/puppetmaster/fileserver.conf";
        "/etc/puppet/tagmail.conf":
            content => template("puppetmaster/tagmail.conf.erb");
         "/var/lib/puppet/reports":
            require => Class["puppet"],
            ensure => directory,
            mode => 750,
            recurse => true,
            owner  => puppet,
            group  => puppet;
    }
}
