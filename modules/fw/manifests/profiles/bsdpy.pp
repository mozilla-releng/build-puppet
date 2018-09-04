# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class fw::profiles::bsdpy {

    case $::fqdn {
        /.*\.mdc1\.mozilla\.com/: {
            include ::fw::roles::ssh_from_rejh_logging
            include ::fw::roles::nrpe_from_nagios
            include ::fw::roles::bsdpy_from_mdc1_releng
        }
        /.*\.mdc2\.mozilla\.com/: {
            include ::fw::roles::ssh_from_rejh_logging
            include ::fw::roles::nrpe_from_nagios
            include ::fw::roles::bsdpy_from_mdc2_releng
        }
        default:{
            # Silently skip other DCs
        }
    }
}
