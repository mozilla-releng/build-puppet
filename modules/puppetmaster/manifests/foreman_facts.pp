# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class puppetmaster::foreman_facts {
    include cron
    include config
    include puppetmaster::settings

    $facturl  = $::config::puppet_server_facturl
    $crontask = '/etc/cron.d/foreman_facts'
    $script   = '/usr/local/sbin/foreman_facts.rb'

    # only install if the facturl is nonempty, but run on every puppetmaster
    $ensure = $facturl? {
        ''      => absent,
        default => present
    }

    case $ensure {
        present: {
            file {
                $crontask:
                    content => template("${module_name}/foreman_facts.cron.erb");
                $script:
                    mode    => filemode(0755),
                    content => template("${module_name}/foreman_facts.rb.erb");
            }
        }
        absent: {
            file {
                [$crontask, $script]:
                    ensure => absent;
            }
        }
    }
}
