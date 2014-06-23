# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define bors::cron($basedir, $owner, $status_location) {
    # status_location is used in the bors-cron.erb template

    include packages::procmail # for lockfile

    file {
        "/etc/cron.d/bors-${title}":
            ensure => absent;
    }
}
