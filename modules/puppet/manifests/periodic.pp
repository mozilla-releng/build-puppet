# Set up puppet to run periodically.
#
# This is done via crontab due to a memory leak in puppet identified by Mozilla
# IT.

class puppet::periodic {
    include settings

    file {
        "/etc/cron.d/puppetcheck.cron":
            content => template("puppet/puppetcheck.cron.erb");
    }
}
