# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class puppetmaster::install {
    include packages::httpd
    include packages::mod_ssl
    include packages::mod_passenger
    include packages::puppetserver
}
