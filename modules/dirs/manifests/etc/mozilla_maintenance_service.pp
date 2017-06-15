# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class dirs::etc::mozilla_maintenance_service {

    include dirs::etc

    file {
        'c:/etc/mozilla_maintenance_service':
            ensure => directory,
    }
}
