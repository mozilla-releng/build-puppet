# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::collectd {
    case $::operatingsystem {
        CentOS: {
            package {
                "collectd":
                    ensure => '5.3.0-2.el6';
                "collectd-apache":
                    ensure => '5.3.0-2.el6';
                "collectd-ascent":
                    ensure => '5.3.0-2.el6';
                "collectd-bind":
                    ensure => '5.3.0-2.el6';
                "collectd-contrib":
                    ensure => '5.3.0-2.el6';
                "collectd-curl":
                    ensure => '5.3.0-2.el6';
                "collectd-curl_json":
                    ensure => '5.3.0-2.el6';
                "collectd-curl_xml":
                    ensure => '5.3.0-2.el6';
                "collectd-dbi":
                    ensure => '5.3.0-2.el6';
                "collectd-debuginfo":
                    ensure => '5.3.0-2.el6';
                "collectd-dns":
                    ensure => '5.3.0-2.el6';
                "collectd-email":
                    ensure => '5.3.0-2.el6';
                "collectd-gmond":
                    ensure => '5.3.0-2.el6';
                "collectd-hddtemp":
                    ensure => '5.3.0-2.el6';
                "collectd-ipmi":
                    ensure => '5.3.0-2.el6';
                "collectd-iptables":
                    ensure => '5.3.0-2.el6';
                "collectd-libvirt":
                    ensure => '5.3.0-2.el6';
                "collectd-memcachec":
                    ensure => '5.3.0-2.el6';
                "collectd-mysql":
                    ensure => '5.3.0-2.el6';
                "collectd-nginx":
                    ensure => '5.3.0-2.el6';
                "collectd-notify_desktop":
                    ensure => '5.3.0-2.el6';
                "collectd-notify_email":
                    ensure => '5.3.0-2.el6';
                "collectd-nut":
                    ensure => '5.3.0-2.el6';
                "collectd-perl":
                    ensure => '5.3.0-2.el6';
                "collectd-pinba":
                    ensure => '5.3.0-2.el6';
                "collectd-ping":
                    ensure => '5.3.0-2.el6';
                "collectd-postgresql":
                    ensure => '5.3.0-2.el6';
                "collectd-python":
                    ensure => '5.3.0-2.el6';
                "collectd-rrdtool":
                    ensure => '5.3.0-2.el6';
                "collectd-sensors":
                    ensure => '5.3.0-2.el6';
                "collectd-snmp":
                    ensure => '5.3.0-2.el6';
                "collectd-varnish":
                    ensure => '5.3.0-2.el6';
                "collectd-write_http":
                    ensure => '5.3.0-2.el6';
                "collectd-write_riemann":
                    ensure => '5.3.0-2.el6';
                "libcollectdclient":
                    ensure => '5.3.0-2.el6';
            }
        }

        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}

