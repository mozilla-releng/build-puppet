# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class puppetmaster::standalone {
    include packages::mercurial
    case $::operatingsystem {
        CentOS: {
            file {
                # NOTE: the toplevel class takes care of setting puppet's startup_type
                # to 'none', as the puppetmaster update here runs 'puppet apply' instead
                "/etc/puppet/update.sh":
                    mode => 0755,
                    owner => root,
                    group => root,
                    content => template("puppetmaster/update.sh.erb");
                "/etc/cron.d/puppetmaster-update.cron":
                    content => template("puppetmaster/puppetmaster-update.cron.erb");
                "/root/.hgrc":
                    mode => 0644,
                    owner => root,
                    group => root,
                    source => "puppet:///modules/users/hgrc";
            }
        }
        default: {
            fail("No puppetmaster implementation for $::operatingsystem")
        }
    }
}
