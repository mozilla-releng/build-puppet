# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mozpool {
    include mozpool::settings
    include mozpool::virtualenv
    include mozpool::config
    include mozpool::daemon
    include mozpool::httpd
    include mozpool::inventorysync
    include mozpool::dbcron
    include tweaks::tcp_keepalive

    file {
        $mozpool::settings::root:
            ensure => directory;
    }
}
