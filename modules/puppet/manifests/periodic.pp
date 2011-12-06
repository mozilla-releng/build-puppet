# Set up puppet to run periodically.
#

class puppet::periodic {
    include config

    file {
        # This is done via crontab due to a memory leak in puppet identified by
        # Mozilla IT.  There is enough splay here to avoid killing the master
        # (configured in puppet.conf)
        "/etc/cron.d/puppetcheck.cron":
            content => template("puppet/puppetcheck.cron.erb");
    }
}
