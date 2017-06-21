# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class fw::profiles::distinguished_puppetmaster {

    include ::fw::roles::puppetmaster_from_all_releng
    include ::fw::roles::puppetmaster_sync_from_all_releng
    include ::fw::roles::bacula_from_scl3_bacula_host
    include ::fw::roles::ssh_from_anywhere
}
