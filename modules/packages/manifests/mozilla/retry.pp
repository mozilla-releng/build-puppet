# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mozilla::retry {
    case $::operatingsystem {
        Darwin,CentOS: {
            file  {
                '/usr/local/bin/retry.py':
                    source => 'puppet:///modules/packages/retry.py',
                    owner  => $users::root::username,
                    group  => $users::root::group,
                    mode   => '0755';
            }
        }
        Windows: {
            #TODO: add windows support https://bugzilla.mozilla.org/show_bug.cgi?id=1113324
        }
        default: {
            fail("Don't know where to put retry on this platform")
        }
    }
}
