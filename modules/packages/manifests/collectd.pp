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
                    ensure => absent;
                "collectd-ascent":
                    ensure => absent;
                "collectd-bind":
                    ensure => absent;
                "collectd-contrib":
                    ensure => absent;
                "collectd-curl":
                    ensure => absent;
                "collectd-curl_json":
                    ensure => absent;
                "collectd-curl_xml":
                    ensure => absent;
                "collectd-dbi":
                    ensure => absent;
                "collectd-debuginfo":
                    ensure => absent;
                "collectd-dns":
                    ensure => absent;
                "collectd-email":
                    ensure => absent;
                "collectd-gmond":
                    ensure => absent;
                "collectd-hddtemp":
                    ensure => absent;
                "collectd-ipmi":
                    ensure => absent;
                "collectd-iptables":
                    ensure => absent;
                "collectd-libvirt":
                    ensure => absent;
                "collectd-memcachec":
                    ensure => absent;
                "collectd-mysql":
                    ensure => absent;
                "collectd-nginx":
                    ensure => absent;
                "collectd-notify_desktop":
                    ensure => absent;
                "collectd-notify_email":
                    ensure => absent;
                "collectd-nut":
                    ensure => absent;
                "collectd-perl":
                    ensure => absent;
                "collectd-pinba":
                    ensure => absent;
                "collectd-ping":
                    ensure => absent;
                "collectd-postgresql":
                    ensure => absent;
                "collectd-python":
                    ensure => absent;
                "collectd-rrdtool":
                    ensure => absent;
                "collectd-sensors":
                    ensure => absent;
                "collectd-snmp":
                    ensure => absent;
                "collectd-varnish":
                    ensure => absent;
                "collectd-write_http":
                    ensure => absent;
                "collectd-write_riemann":
                    ensure => absent;
                "libcollectdclient":
                    ensure => '5.3.0-2.el6';
            }
        }

        Ubuntu: {
            case $::operatingsystemrelease {
                12.04: {
                    package {
                        ["collectd-core", "collectd", "libcollectdclient1", "libcollectdclient-dev", "collectd-dbg", "collectd-dev", "collectd-utils"]:
                            ensure => '5.3.0';
                    }
                }
                14.04: {
                    package {
                        ["collectd-core", "collectd", "libcollectdclient1", "libcollectdclient-dev", "collectd-dbg", "collectd-dev", "collectd-utils"]:
                            ensure => '5.4.0-3ubuntu2';
                    }
                }
                default: {
                    fail("Unrecognized Ubuntu version $::operatingsystemrelease")
                }
            }
        }

        Darwin: {
            packages::pkgdmg {
                'collectd':
                    version => '5.3.0',
                    os_version_specific => true,
                    private => false;
            }
        }

        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}

