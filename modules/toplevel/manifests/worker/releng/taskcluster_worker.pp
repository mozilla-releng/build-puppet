# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class toplevel::worker::releng::taskcluster_worker inherits toplevel::worker::releng {

    include ::taskcluster_worker

    if ($::operatingsystem == 'Darwin') {
        # ensure generic-worker is disabled, in case this machine previously ran it
        file {
            '/Library/LaunchAgents/net.generic.worker.plist':
                ensure => absent,
        }
    }
}
