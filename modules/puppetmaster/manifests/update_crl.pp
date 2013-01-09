# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class puppetmaster::update_crl {
    include ::config

    if $::config::crl_sync_url != "" {
        case $::operatingsystem {
            CentOS: {
                file {
                    "/etc/puppet/update_crl.sh":
                        mode => 0755,
                        require => Class["packages::diffutils"],
                        content => template("puppetmaster/update_crl.sh.erb");
                    "/etc/cron.d/update_crl.cron":
                        require => File["/etc/puppet/update_crl.sh"],
                        content => template("puppetmaster/update_crl.cron.erb");
                }
            }
            default: {
                fail("puppetmaster::service support missing for $::operatingsystem")
            }
        }
    }
}
