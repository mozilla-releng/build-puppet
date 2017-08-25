# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# All buildbot slaves (both build and test) are subclasses of this class

class toplevel::slave::releng inherits toplevel::slave {
    include dirs::builds::slave
    include buildslave
    include instance_metadata
    include clean::appstate

    # packages common to all slaves
    include packages::mozilla::tooltool
    include packages::wget
    include packages::mozilla::py27_mercurial

    if ($::operatingsystem == Darwin) {
        include packages::mozilla::py27_virtualenv
    }

    if ($::operatingsystem == Windows) {
        include tweaks::memory_paging
        include tweaks::nouac
        include tweaks::ntfs_options
        include tweaks::process_priority
        include tweaks::pwrshell_options
        include tweaks::server_initialize
        include tweaks::windows_network_opt_netsh
        include tweaks::windows_network_opt_registry
        include packages::mozilla::git
        include packages::nsis
        include packages::psutil
        include packages::mozilla::py27_virtualenv
        include packages::pywin32
        include packages::mapi_headers
        include packages::yasm
        include fw::windows_exceptions
        include fw::windows_settings
        include hardware::ec2_config
        include vnc
    }
    case $::kernel {
        'Linux': {
            # authorize aws-manager to reboot instances
            users::builder::extra_authorized_key {
                'aws-ssh-key': ;
            }
        }
    }
    if ($::config::enable_mig_agent) {
        case $::operatingsystem {
            # Darwin support is coming soon
            'CentOS', 'RedHat', 'Ubuntu', 'Darwin': {
                include mig::agent::checkin
            }
        }
    }
}
