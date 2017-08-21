# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class fw::roles::taskcluster_host_secrets_from_dc_test {
    include fw::networks

    fw::rules { 'allow_taskcluster_host_secrets_from_dc_test':
        sources =>  $::fw::networks::dc_test,
        app     => 'http'
    }
}