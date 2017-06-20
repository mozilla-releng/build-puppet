# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Configure the kernel to send keepalive packets every 120s on idle tcp
# connections, and fail after a total of 180s of no response.  This is pretty
# conservative, but allows us to fail fast when a TCP connection silently goes
# away.  This is more common than you might think: it is often caused by
# session state loss on firewalls, or by a host failure at the other end of the
# connection.

class tweaks::tcp_keepalive {
    case $::operatingsystem {
        CentOS, Ubuntu: {
            sysctl::value {
                # wait 120 seconds since last data packet (or good probe
                # response) is received before sending the first probe
                'net.ipv4.tcp_keepalive_time':
                    value => 120;
                # when a keepalive probe fails (times out), send another after
                # 5 seconds
                'net.ipv4.tcp_keepalive_intvl':
                    value => 5;
                # kill the TCP connection after 12 probes with no response
                'net.ipv4.tcp_keepalive_probes':
                    value => 12;
            }
        }
        default: {
            notice("Don't know how to set keepalive time on ${::operatingsystem}")
        }
    }
}

