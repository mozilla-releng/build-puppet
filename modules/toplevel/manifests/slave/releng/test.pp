# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class toplevel::slave::releng::test inherits toplevel::slave::releng {
    include talos
    include vnc
    include users::builder::autologin
    include ntp::daemon
    include runner::tasks::cleanup
    include dirs::builds::hg_shared
    include dirs::builds::git_shared
    include dirs::builds::tooltool_cache
    if ($::operatingsystem != Windows) {
        include tweaks::fonts
        include packages::fonts
        include packages::unzip
    }

    case $::operatingsystem {
        'Ubuntu': {
            include runner::tasks::update_shared_repos
            include runner::tasks::checkout_tools
            include runner::tasks::restart_services
            include runner::tasks::check_ami
            include packages::virtualenv
            class {
                'runner::tasks::purge_builds':
                    required_space => 4;
            }
        }
        'Darwin': {
            include runner::tasks::update_shared_repos
            include runner::tasks::checkout_tools
            include tweaks::disable_bonjour
            class {
                'runner::tasks::purge_builds':
                    required_space => 4;
            }
        }
        'Windows': {
            include disableservices::disable_indexing
            include disableservices::disable_win_defend
            include disableservices::disable_win_driver_signing
            include disableservices::disableupdates
            include packages::mozilla::dumbwin32proc
            include packages::mozilla::mozilla_maintenance_service
            include packages::nvidia_drivers
            include packages::win7sdk
            include tweaks::disable_desktop_interruption
            include tweaks::memory_paging
            include tweaks::sync_logon_scripts
        }
    }

    if ($::operatingsystem != Windows) {
        include runner::tasks::config_hgrc

        class {
            'slave_secrets':
                slave_type => 'test';
        }
    }
}
