# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class fw::roles::slave_api_from_releng_web_cluster {
    include fw::networks

    fw::rules { 'allow_slave_api_from_releng_web_cluster':
        sources =>  $::fw::networks::releng_web_cluster,
        app     => 'slave_api'
    }
}
