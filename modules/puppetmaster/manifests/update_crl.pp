class puppetmaster::update_crl {
    include config

    if $config::crl_sync_url != "" {
        case $operatingsystem {
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
                fail("puppetmaster::service support missing for $operatingsystem")
            }
        }
    }
}
