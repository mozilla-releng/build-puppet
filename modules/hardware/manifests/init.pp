# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class hardware {
    include config

    # SeaMicro nodes can start up with incorrect time - see bug 789064
    if ($::manufacturer == 'SeaMicro' and $::productname == 'SM10000-XE') {
        # only known to work on CentOS so far, although it should work on any Linux
        if ($::operatingsystem == 'CentOS') {
            file {
                '/etc/e2fsck.conf':
                    source => 'puppet:///modules/hardware/seamicro-e2fsck.conf';
            }
        }
    }

    # Nodes running IPMI-compliant hardware should install OpenIPMI
    if (($::manufacturer == 'HP' and $::productname =~ /ProLiant/) or
        ($::boardmanufacturer == 'Supermicro' and $::boardproductname == 'X8SIL') or # ix700C
        ($::boardmanufacturer == 'Supermicro' and $::boardproductname == 'X8SIT')) { # ix21x4
        if ($::kernel == 'Linux') {
            include hardware::ipmitool
        }
    }

    if (($::boardmanufacturer == 'Supermicro' and $::boardproductname == 'X8SIL') or # ix700C
        ($::boardmanufacturer == 'Supermicro' and $::boardproductname == 'X8SIT')) { # ix21x4
        if ($::kernel == 'Linux') {
        # disable some broken NIC features
            include tweaks::i82574l_aspm
        }
    }

    # OK, so it's not strictly "hardware", but stlil..
    if ($::virtual == 'vmware') {
        if ($::kernel == 'Linux') {

            # kernels should use clocksource=pit to get proper timing info
            # and, of course, this is different between RHEL-based and Ubuntu
            # systems!
            case $::operatingsystem {
                CentOS: {
                    if ($config::vmwaretools_version) {
                        class {
                            'vmwaretools':
                                version     => $config::vmwaretools_version,
                                archive_md5 => $config::vmwaretools_md5,
                                archive_url => "http://${config::data_server}/repos/private/vmware";
                        }
                    }
                    augeas {
                        'vmware-clocksource':
                            context => '/files/etc/grub.conf',
                            changes => [
                                'set title[1]/kernel/clocksource pit',
                            ];
                    }
                }
                Ubuntu: {
                    augeas {
                        'vmware-clocksource':
                            context => '/files/etc/default/grub',
                            changes => [
                                'set GRUB_CMDLINE_EXTRA clocksource=pit'
                            ];
                    }
                    case $::operatingsystemrelease {
                        12.04,14.04: {
                            if ($config::vmwaretools_version) {
                                class {
                                    'vmwaretools':
                                        version     => $config::vmwaretools_version,
                                        archive_md5 => $config::vmwaretools_md5,
                                        archive_url => "http://${config::data_server}/repos/private/vmware";
                                }
                            }
                        }
                        16.04: {
                            class {'packages::open_vm_tools': }
                        }
                        default: {
                            fail("Unrecognized Ubuntu version ${::operatingsystemrelease}")
                        }
                    }
                }
            }
        }
    }
    if ($::virtual == 'xenhvm') {
        case $::operatingsystem {
            Ubuntu: {
                case $::operatingsystemrelease {
                    16.04: {
                        class {'packages::xe_guest_utilities': }
                    }
                }
            }
        }
    }
    if ($::operatingsystem == 'Windows') {
        include hardware::hddoff
        include hardware::highperformance
    }
}
