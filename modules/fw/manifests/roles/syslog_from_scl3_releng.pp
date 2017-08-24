# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class fw::roles::syslog_from_scl3_releng {
    include fw::networks

    fw::rules { 'allow_syslog_udp_from_scl3_releng':
        sources => [    $::fw::networks::scl3_releng,
                        $::fw::networks::ad_scl3,
                        $::fw::networks::releng_web_cluster,
                        $::fw::networks::releng_web_admin ],
        app     => 'syslog_udp'
    }
    fw::rules { 'allow_syslog_tcp_from_scl3_releng':
        sources => [    $::fw::networks::scl3_releng,
                        $::fw::networks::ad_scl3,
                        $::fw::networks::releng_web_cluster,
                        $::fw::networks::releng_web_admin ],
        app     => 'syslog_tcp'
    }
}
