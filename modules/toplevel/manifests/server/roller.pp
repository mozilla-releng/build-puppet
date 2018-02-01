# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class toplevel::server::roller inherits toplevel::server {
    include ::security

    assert {
      'roller-high-security':
        condition => $::security::high;
    }

    if (has_aspect('dev')) {
        $roller_instance_title = 'dev'
    }
    elsif (has_aspect('prod')) {
        $roller_instance_title = 'prod'
    } else {
        fail("Environemnt must be specified in \$aspects node-scope variable")
    }

    roller::instance {
        $roller_instance_title:
            port       => '8000';
    }
}
