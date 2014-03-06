# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::puppetserver {
    include packages::puppet

    # puppet-server requires passenger, which is in its own repo
    realize(Packages::Yumrepo['passenger'])

    case $::operatingsystem {
        CentOS: {
            package {
                "puppet-server":
                    require => Class["packages::puppet"],
                    ensure => $packages::puppet::new_puppet_rpm_version;
            }
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
