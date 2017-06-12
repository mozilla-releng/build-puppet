# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class toplevel::worker::releng inherits toplevel::worker {
    include instance_metadata
    include clean::appstate

    # packages common to all workers
    include dirs::tools
    include packages::mozilla::python27
    include packages::mozilla::tooltool
    include packages::wget
    include packages::mozilla::py27_mercurial
    # TODO: run mig agent on boot?
    include mig::agent::daemon

    # not sure why these are required on Darwin..
    if ($::operatingsystem == 'Darwin') {
        include packages::mozilla::py27_virtualenv
        include buildslave::install
    }

    case $::kernel {
        'Linux': {
            # authorize aws-manager to reboot instances
            users::builder::extra_authorized_key {
                'aws-ssh-key': ;
            }
        }
    }

    # ensure runner is actually disabled, in case this machine was once set up
    # to run buildbot (temporary)
    case $::operatingsystem {
        'Darwin': {
            file {
                '/Library/LaunchAgents/com.mozilla.runner.plist':
                    ensure => absent,
            }
        }

        'Ubuntu': {
            service {
                'runner':
                    provider  => 'systemd',
                    hasstatus => false,
                    enable    => false;
            }
        }

        default: {
            fail("not (yet) supported on ${::operatingsystem}")
        }
    }
}
