# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Limits number of Challenge ACK sent per second, as recommended
# in RFC 5961 (Improving TCP's Robustness to Blind In-Window Attacks)

# This is suppose to be a temporary patch to prevent Linux TCP ChallengeAck
# side channel attack.  Although it will be permanent in the releng use case
# since upgrading all kernels to >= 4.7 isn't feasible.

# See https://bugzilla.mozilla.org/show_bug.cgi?id=1294125

class tweaks::tcp_challenge_ack_limit {
    case $::operatingsystem {
        CentOS, Ubuntu: {
            sysctl::value {
                'net.ipv4.tcp_challenge_ack_limit':
                    value => 999999999;
            }
        }
        default: {
            notice("Don't know how to set tcp_challenge_ack_limit on ${::operatingsystem}")
        }
    }
}