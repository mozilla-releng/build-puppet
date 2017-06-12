# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# All QA slaves (both mozmill-ci and tps-ci) are subclasses of this class.
class toplevel::slave::qa inherits toplevel::slave {
    include vnc

    class {
        'gui':
            on_gpu        => true,
            screen_width  => 1024,
            screen_height => 768,
            screen_depth  => 32,
            refresh       => 60;
    }

    if ($::config::enable_mig_agent) {
        case $::operatingsystem {
            # Darwin support is coming soon
            'CentOS', 'RedHat', 'Ubuntu': {
                include mig::agent::daemon
            }
        }
    }

}
