# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class shared::execonce::base {
    case $::operatingsystem {
        windows: {
            # puppet's $libdir gets blown away on every agent run,
            # so we use our own subdirectory (and create it)
            include dirs::programdata::puppetagain
            $semaphore_dir = 'C:/programdata/puppetagain/semaphores'
            file {
                $semaphore_dir:
                    ensure => directory;
            }
        }
        default: {
            # On POSIX, this directory survives from run to run of the agent.
            $semaphore_dir = '/var/lib/puppet'
        }
    }
}
