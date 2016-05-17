# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class cruncher {
    include cruncher::install
    include cruncher::config
    include cruncher::httpd
    include cruncher::slave_health
    include cruncher::reportor
    include cruncher::allthethings
    include cruncher::cron
}
