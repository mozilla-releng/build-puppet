# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class puppetmaster::extsyncs {
    include config
    include puppetmaster::settings

    $extsyncs = keys($::config::puppetmaster_extsyncs)

    puppetmaster::extsync {
        $extsyncs:
            ensure => $puppetmaster::settings::is_distinguished ? {
                true    => 'present',
                default => 'absent'
            };
    }
}
