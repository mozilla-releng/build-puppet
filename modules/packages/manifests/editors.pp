# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::editors {
    case $::operatingsystem {
        CentOS: {
            package {
                'nano':
                    ensure => latest;
                'vim-minimal':
                    ensure => latest;
            }
        }
        Ubuntu: {
            package {
                ['nano', 'vim']:
                    ensure => latest;
            }
        }

        Darwin: {
            # installed by default
        }

        Windows: {
            # This is currently handled by MDT. This item will be reviewed after the installation method, an autoit script, is replaced.
        }

        default: {
            fail("cannot install on ${::operatingsystem}")
        }
    }
}
