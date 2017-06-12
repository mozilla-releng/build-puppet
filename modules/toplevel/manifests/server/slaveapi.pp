# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class toplevel::server::slaveapi inherits toplevel::server {
    include ::security
    assert {
      'slaveapi-high-security':
        condition => $::security::high;
    }

    if (has_aspect('dev')) {
        $slaveapi_title = 'dev'
    }
    else {
        $slaveapi_title = 'prod'
    }

    slaveapi::instance {
        $slaveapi_title:
            listenaddr => '0.0.0.0',
            port       => '8080';
    }
}
