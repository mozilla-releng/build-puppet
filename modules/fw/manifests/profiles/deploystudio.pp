# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class fw::profiles::deploystudio {

    case $::fqdn {
        /.*\.mdc1\.mozilla\.com/: {
            include ::fw::roles::vnc_from_anywhere_logging
            include ::fw::roles::ssh_from_anywhere_logging
        }
        default:{
            # Silently skip other DCs
        }
    }
}
