# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class puppetmaster::standalone {
    include packages::mercurial
    case $::operatingsystem {
        CentOS: {
            file {
                # Touch /etc/puppet/standalone to enable "puppet apply" style updates in puppet::periodic
                "/etc/puppet/update.sh":
                    mode => 0755,
                    owner => root,
                    group => root,
                    content => template("puppetmaster/update.sh.erb");
                "/etc/puppet/standalone":
                    content => "";
                "/root/.hgrc":
                    mode => 0644,
                    owner => root,
                    group => root,
                    source => "puppet:///modules/users/hgrc";
            }
        }
    }
}
