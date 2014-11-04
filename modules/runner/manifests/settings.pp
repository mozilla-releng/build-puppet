# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# settings for runner
class runner::settings {
    case $::operatingsystem {
        'CentOS', 'Ubuntu', 'Darwin': {
            $root = '/opt/runner'
        }

        default: {
            fail("Unsupported OS ${::operatingsystem}")
        }
    }
    $taskdir = "${root}/tasks.d"
    $configdir = "${root}/config.d"
}
