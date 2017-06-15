# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class dirs::etc {
    case $::operatingsystem {
        windows: {
            $dir = 'c:/etc'
            file {
                'c:/etc':
                    ensure => directory,
            }
        }
        default: {
            # everywhere else, we assume /etc exists; to do otherwise
            # introduces a lot of tricky depenency cycles due to configuration
            # files autorequiring /etc
            $dir = '/etc'
        }
    }
}
