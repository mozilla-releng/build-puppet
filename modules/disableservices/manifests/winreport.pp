# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

#Disable Windows reporting service

class disableservices::winreport {
    if ($::env_os_version != 2008) {
        service {'WerSvc':
            enable => false,
        }
    }
}
