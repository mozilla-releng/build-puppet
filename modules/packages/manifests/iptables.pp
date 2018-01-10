# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::iptables {

    # We purposely install iptables with exec so not to clash with the resources
    # defined in the Firewall module. This issue has been fixed in puppet 4.3.0
    # https://tickets.puppetlabs.com/browse/PUP-1963
    # https://tickets.puppetlabs.com/browse/PUP-5874
    case $::operatingsystem {
        CentOS: {
            exec { 'install iptables':
                command => '/usr/bin/yum install iptables -y',
                creates => '/sbin/iptables';
            }
            exec { 'install ip6tables':
                command => '/usr/bin/yum install iptables-ipv6 -y',
                creates => '/sbin/ip6tables';
            }
        }
        Ubuntu: {
            # Install iptables on Ubuntu
            case $::operatingsystemrelease {
                16.04: {
                    # ip6tables is installed by iptables package, so we don't have separate packages
                    exec { 'install iptables':
                        command => '/usr/bin/apt-get install iptables -y',
                        creates => '/sbin/iptables';
                    }
                    # Although the iptables rules are effective, they will automatically be deleted if the server reboots.
                    # To make sure that they remain in effect, we can use a package called IP-Tables persistent.
                    exec { 'install iptables-persistent':
                        command => '/usr/bin/apt-get install iptables-persistent -y',
                        creates => '/usr/share/doc/iptables-persistent';
                    }
                }
                12.04: {
                    # 12.04 does not have a problems having the firewall puppet module install iptables
                }
                default: {
                    fail("No iptables package is defined for ${::operatingsystem}-${::operatingsystemrelease}")
                }
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
