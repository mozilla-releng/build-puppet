# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class fw::apps {
    $app_proto_port = { 'ssh'                 => { proto => 'tcp', port  => '22' },
                        'vnc'                 => { proto => 'tcp', port  => '5900' },
                        'nrpe'                => { proto => 'tcp', port  => '5666' },
                        'http'                => { proto => 'tcp', port  => '80' },
                        'https'               => { proto => 'tcp', port  => '443' },
                        'dhcp_server'         => { proto => 'udp', port  => '67' },
                        'tftp'                => { proto => 'udp', port  => '69' },
                        'rpc_udp'             => { proto => 'udp', port  => '111' },
                        'rpc_tcp'             => { proto => 'tcp', port  => '111' },
                        # These ports (stat) are set static in /etc/nfs.conf
                        'stat_udp'            => { proto => 'udp', port  => '1019-1022' },
                        'stat_tcp'            => { proto => 'tcp', port  => '1019-1022' },
                        'nfs_udp'             => { proto => 'udp', port  => '2049' },
                        'nfs_tcp'             => { proto => 'tcp', port  => '2049' },
                        'smb_udp'             => { proto => 'udp', port  => '137-139' },
                        'smb_tcp'             => { proto => 'tcp', port  => '137-139' },
                        'smb_ip'              => { proto => 'tcp', port  => '445' },
                        'afp'                 => { proto => 'tcp', port  => '548' },
                        'ds_http'             => { proto => 'tcp', port  => '60080' },
                        'ds_https'            => { proto => 'tcp', port  => '60443' },
                        'puppet'              => { proto => 'tcp', port  => '8140' },
                        'bacula'              => { proto => 'tcp', port  => '9102' },
                        'dep_signing'         => { proto => 'tcp', port  => '9110' },
                        'rel_signing'         => { proto => 'tcp', port  => '9120' },
                        'nightly_signing'     => { proto => 'tcp', port  => '9100' },
                        'syslog_udp'          => { proto => 'udp', port  => '514' },
                        'syslog_tcp'          => { proto => 'tcp', port  => '514' },
                        'slave_api'           => { proto => 'tcp', port  => '8080' },
                        'roller_api'          => { proto => 'tcp', port  => '8000' },
                        'buildbot_http_range' => { proto => 'tcp', port  => '8000-8999' },
                        'buildbot_rpc_range'  => { proto => 'tcp', port  => '9000-9999' },
                        }
}
