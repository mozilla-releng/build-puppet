# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define puppetmaster::extsync($ensure) {
    include config
    $extsync = $title
    $params = $::config::puppetmaster_extsyncs[$extsync]

    # call out to a class named after the extsync, with the parameters provided
    # in the config.
    create_resources('class', {
        "puppetmaster::extsync::${extsync}" => merge({ensure => $ensure}, $params),
    })
}
