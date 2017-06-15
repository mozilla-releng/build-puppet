# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class dirs::tools {
    case $::operatingsystem {
    # Creating a Windows tool directory so it is available as we work towards a more parallel directory structure with posix 
        Windows: {
            file {
                'C:/tools':
                    ensure => directory;
            }
        }
        default: {
            file {
                '/tools':
                    ensure => directory;
            }
        }
    }
}
