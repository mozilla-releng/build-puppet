# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mockbuild::services {
    include ::config
    include packages::mozilla::supervisor
    include packages::xvfb

    supervisord::supervise {
        'Xvfb':
          command => 'Xvfb :2 -screen 0 1280x1024x24',
          user    => $::config::builder_username;
    }
}
