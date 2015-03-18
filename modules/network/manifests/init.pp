# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class network {
    include ::config
    include network::resolv

    # remove some old entries from /etc/hosts (#938629)
    host {
        ['puppet', 'repos']: ensure => absent;
    }

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
            # Some of our systems seem to lack en1, either due to hardware or software issues.
            # Usually a hard power cycle will fix this, but since the goal is to disable wireless,
            # we can count "no en1" as a success condition.
            if ($::macaddress_en1 != "") {
                exec {
                    "disable-wifi":
                        command => "/usr/sbin/networksetup -setairportpower en1 off",
                        unless => "/usr/sbin/networksetup -getairportpower en1 | egrep 'Off'";
                }
            }
            # bug 1144206 frequent talos failures caused by multicast hello protocol causing dns
            # timeouts and not allowing g.m.o to resolve
            if ($::macosx_productversion_major == "10.10") {
                exec {
                   "disable multicast":
                        command => "/usr/libexec/PlistBuddy -c \"Add :ProgramArguments: string --no-multicast\" /System/Library/LaunchDaemons/com.apple.discoveryd.plist",
                        unless => "/usr/bin/defaults read /System/Library/LaunchDaemons/com.apple.discoveryd.plist | egrep 'no-multicast'"
                }
             }
        }
    }
}
