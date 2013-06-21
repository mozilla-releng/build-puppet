# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class network {
    include ::config
    # always set the hostname to the fqdn
    case $::operatingsystem {
        CentOS: {
            file {
                "/etc/sysconfig/network":
                    content => "NETWORKING=yes\nHOSTNAME=$fqdn\n",
                    notify => Exec['run-hostname-centos'];
            }

            exec {
                "run-hostname-centos":
                    command => "/bin/hostname $fqdn",
                    refreshonly => true;
            }
        }
        Darwin: {
            # nothing to do
        }
    }

    if ($::config::manage_ifcfg) {
        # ensure interface configuration is correct
        # (in particular, don't use peer NTP configuration, as that comes from puppet)
        case $::operatingsystem {
            CentOS: {
                file {
                    "/etc/sysconfig/network-scripts/ifcfg-eth0":
                        content => template("network/centos6-ifcfg-eth0.erb");
                }
            }
            Darwin: {
                # nothing to do
            }
        }
    }

    # disable wifi
    case $::operatingsystem {
        CentOS: {
            # existing CentOS systems do not have wifi hardware
        }
        Darwin: {
            exec {
                "disable-wifi":
                    command => "/usr/sbin/networksetup -setairportpower en1 off",
                    unless => "/usr/sbin/networksetup -getairportpower en1 | egrep 'Off'";
            }
        }
    }
}
