class puppet::periodic {
    include puppet
    include config
    include puppet::puppetize_sh
    include dirs::usr::local::bin

    case $::operatingsystem {
        CentOS: {
            file {
                # This is done via crontab due to a memory leak in puppet identified by
                # Mozilla IT.  There is enough splay here to avoid killing the master
                # (configured in the crontask)
                "/etc/cron.d/puppetcheck.cron":
                    content => template("puppet/puppetcheck.cron.erb");
            }
        }
        Darwin: {
            # Launchd substitutes for crond on Darwin.  This runs a shell snippet
            # which adds some splay so that we don't kill the master every half-hour
            file {
                "/Library/LaunchDaemons/com.mozilla.puppet.plist":
                    owner => root,
                    group => wheel,
                    mode => 0644,
                    source => "puppet:///modules/puppet/puppet-periodic.plist";
                "/usr/local/bin/run-puppet.sh":
                    ensure => absent;
            }
        }
        default: {
            fail("puppet::periodic support missing for $operatingsystem")
        }
    }
}
