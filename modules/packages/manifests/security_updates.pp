# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::security_updates {

    # This class contains pinned versions of package updates
    # See bug 1319455
    anchor {
        'packages::security_updates::begin': ;
        'packages::security_updates::end': ;
    }

    case $::operatingsystem {
        CentOS: {
            realize(Packages::Yumrepo['security_update_1319455'])
            Anchor['packages::security_updates::begin'] ->
            package {
                "cups-libs":
                    ensure => "1.4.2-74.el6";

                ["libxml2", "libxml2-python"]:
                    ensure => "2.7.6-21.el6";

                "nspr":
                    ensure => "4.11.0-1.el6";

                ["samba-client", "samba-common", "samba-winbind", "samba-winbind-clients"]:
                    ensure => "3.6.23-36.el6_8";
            } -> Anchor['packages::security_updates::end']
        }
        Ubuntu: {
            # Do nothing yet
        }
        Darwin: {
            # Do nothing yet
        }
        Windows: {
            # Do nothing yet
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
