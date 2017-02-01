# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class toplevel::worker::releng inherits toplevel::worker {
    include instance_metadata
    include clean::appstate

    # packages common to all slaves
    include packages::mozilla::tooltool
    include packages::wget
    include packages::mozilla::py27_mercurial
    # TODO: run mig agent on boot?
    include mig::agent::daemon
    include packages::mozilla::py27_virtualenv

    include taskcluster_worker

    file { ['/tools', '/tools/buildbot/', '/tools/buildbot/bin']:
        ensure => 'directory',
    } -> file { '/tools/buildbot/bin/python':
        ensure => 'link',
        target => '/tools/python27/bin/python2.7',
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
    file {
        "/Library/LaunchAgents/com.mozilla.runner.plist":
            ensure => absent,
    }
}
