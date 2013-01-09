# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class puppetmaster {
    include puppetmaster::install
    include puppetmaster::config
    include puppetmaster::service
    include puppetmaster::sync_data
    include puppetmaster::update_crl
}
