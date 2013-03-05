# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Basically anything that is *not* a slave is a subclass of this class.  These
# are machines that are generally up for a long time and expected to be online.

class toplevel::server inherits toplevel::base {
    include puppet::periodic
    include ntp::daemon
    include smarthost
    include disableservices::server
    include ganglia
    include nrpe
    include packages::strace
}
