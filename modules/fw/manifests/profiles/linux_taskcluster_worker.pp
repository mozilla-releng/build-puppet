# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class fw::profiles::linux_taskcluster_worker {

    case $::fqdn {
        /.*\.(scl3|mdc1|mdc2)\.mozilla\.com/: {
            include ::fw::roles::vnc_from_rejh_logging
            include ::fw::roles::ssh_from_rejh_logging
            include ::fw::roles::ssh_from_slaveapi
        }
        default:{
            # Silently skip other DCs
        }
    }
}
