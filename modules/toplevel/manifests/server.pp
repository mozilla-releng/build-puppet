# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Basically anything that is *not* a slave is a subclass of this class.  These
# are machines that are generally up for a long time and expected to be online.

class toplevel::server inherits toplevel::base {
    include puppet::periodic
    include ntp::daemon
    include smarthost
    include cron
    include disableservices::server
    if $::operatingsystem == 'CentOS' {
        include ganglia
        include nrpe::check::ganglia
    }
    include nrpe
    include nrpe::check::puppet_agent
    include packages::strace
    include packages::netcat
    include users::people
}
