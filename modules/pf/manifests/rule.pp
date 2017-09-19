# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define pf::rule (
        $action    = undef,
        $direction = undef,
        $log       = undef,
        $quick     = undef,
        $interface = undef,
        $af        = undef,
        $protocol  = undef,
        $src_addr  = undef,
        $src_port  = undef,
        $dst_addr  = undef,
        $dst_port  = undef,
        $tcp_flags = undef,
        $state     = undef,
) {

    include ::pf

    $_action    = $action ? { /^(pass|drop|block)$/ => $action } # Explicitly fail if action is undef
    $_direction = $direction ? { /^(in|out)$/ => " ${direction}" }    # Explicitly fail if direction is undef
    $_log       = $log ? { true => ' log', default => '' }
    $_quick     = $quick ? { true => ' quick', default => '' }
    if $interface {  $_interface = " on ${interface}" } else { $_interface = '' }
    $_af        = $af ? { /^(inet|inet6)$/ => " ${af}", undef => '' }
    if $protocol { $_protocol = " proto ${protocol}" } else { $_protocol = '' }
    if $src_addr { $_src_addr = " from ${src_addr}" } else { $_src_addr = ' from any' }
    if $src_port { $_src_port = " port ${src_port}" } else { $_src_port = '' }
    if $dst_addr { $_dst_addr = " to ${dst_addr}" } else { $_dst_addr = ' to any' }

    if $dst_port {
        # Split the port ranges (or not)
        $port_range = split($dst_port, '-')

        # if there is a second element, set as an inclusive port range
        if $port_range[1] {
            $_dst_port = " port ${port_range[0]}:${port_range[1]}"
        } else {
            $_dst_port = " port ${dst_port}"
        }
    } else {
        $_dst_port = ''
    }

    if $tcp_flags { $_tcp_flags = " flags ${tcp_flags}" } else { $_tcp_flags = '' }
    if $state { $_state = " ${state}" } else { $_state = '' }

    concat::fragment { "rule_${name}":
        target  => "${::pf::pf_dir}/rules.conf",
        content => template('pf/rule.erb'),
    }
}
