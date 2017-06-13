# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Ensure that a buildslave starts up on this machine

class buildslave::startup {
    anchor {
        'buildslave::startup::begin': ;
        'buildslave::startup::end': ;
    }

    include ::shared
    include buildslave::install
    include users::root

    case $::operatingsystem {
        # everyone but windows uses runslave.py in the same place
        Windows: {
                file {
                    'C:/programdata/puppetagain/runslave.py':
                        source  => 'puppet:///modules/buildslave/runslave.py';
            }
        }
        default: {
            include dirs::usr::local::bin
            file {
                '/usr/local/bin/runslave.py':
                    source => 'puppet:///modules/buildslave/runslave.py',
                    owner  => 'root',
                    group  => $users::root::group,
                    mode   => '0755';
            }
        }
    }
    # select an implementation class based on operating system
    $startuptype = $::operatingsystem ? {
        CentOS      => 'runner',
        Darwin      => 'runner',
        Ubuntu      => 'runner',
        Windows     => 'runner',
    }
    Anchor['buildslave::startup::begin'] ->
    class {
        "buildslave::startup::${startuptype}":
    } -> Anchor['buildslave::startup::end']
}
