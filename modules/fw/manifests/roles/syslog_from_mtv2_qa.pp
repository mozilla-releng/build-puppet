# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class fw::roles::syslog_from_mtv2_qa {
    include fw::networks

    fw::rules { 'allow_syslog_udp_from_mtv2_qa':
        sources =>  $::fw::networks::mtv2_qa,
        app     => 'syslog_udp'
    }
    fw::rules { 'allow_syslog_tcp_from_mtv2_qa':
        sources =>  $::fw::networks::mtv2_qa,
        app     => 'syslog_tcp'
    }
}
