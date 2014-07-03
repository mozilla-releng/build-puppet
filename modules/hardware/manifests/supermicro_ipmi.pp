# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class hardware::supermicro_ipmi {
    include config
    include packages::wget
    include hardware::ipmitool

    $script_file = "/root/upgrade_supermicro_ipmi.sh"

    # set up parameters.  These files are private because Supermicro doesn't allow us
    # to redistribute, but they are easily downloaded from
    # http://www.supermicro.nl/ResourceApps/BIOS_IPMI.aspx
    case "${::boardmanufacturer} ${::boardproductname}" {
        'SuperMicro X8SIT': {
            $bios_url = "http://${::config::data_server}/repos/private/firmware/SMT_312.zip"
            $expected_version = '3.12'
        }
        'SuperMicro X8SIL': {
            $bios_url = "http://${::config::data_server}/repos/private/firmware/SMT_313.zip"
            $expected_version = '3.13'
        }
        default: {
            $expected_version = undef
        }
    }

    # TEMPORARY: only do this on a few hosts..
    case "${::fqdn}" {
        "b-linux64-ix-0001.build.releng.scl3.mozilla.com",
        "b-linux64-ix-0002.build.releng.scl3.mozilla.com",
        "b-linux64-ix-0003.build.releng.scl3.mozilla.com",
        "talos-linux32-ix-031.test.releng.scl3.mozilla.com",
        "talos-linux32-ix-032.test.releng.scl3.mozilla.com",
        "talos-linux32-ix-033.test.releng.scl3.mozilla.com",
        "talos-linux32-ix-034.test.releng.scl3.mozilla.com",
        "talos-linux32-ix-035.test.releng.scl3.mozilla.com",
        "talos-linux64-ix-031.test.releng.scl3.mozilla.com",
        "talos-linux64-ix-032.test.releng.scl3.mozilla.com",
        "talos-linux64-ix-033.test.releng.scl3.mozilla.com",
        "talos-linux64-ix-034.test.releng.scl3.mozilla.com",
        "talos-linux64-ix-035.test.releng.scl3.mozilla.com",
        "foopy39.p1.releng.scl3.mozilla.com",
        "foopy116.tegra.releng.scl3.mozilla.com",
        "foopy117.tegra.releng.scl3.mozilla.com": {
            $do_upgrade = true
        }
        default: {
            $do_upgrade = false
        }
    }

    if $do_upgrade and $expected_version and $::supermicro_ipmi_version != $expected_version {
        file {
            $script_file:
                mode => 0755,
                content => template("${module_name}/upgrade_supermicro_ipmi.sh.erb");
        }
        exec {
            $script_file:
                logoutput => true,
                require => [
                    Class['packages::wget'],
                    Class['hardware::ipmitool'],
                ];
        }
    } else {
        file {
            $script_file:
                ensure => absent;
        }
    }
}
