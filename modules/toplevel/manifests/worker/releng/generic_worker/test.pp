# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class toplevel::worker::releng::generic_worker::test inherits toplevel::worker::releng::generic_worker {
    include talos
    include vnc
    include ntp::daemon
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
        }
        'Darwin': {
            include tweaks::disable_bonjour
            # This can be removed after ESR52
            # See 1396266
            include dirs::tools::buildbot::bin
            include dirs::tools::misc_python
            file {
                '/tools/buildbot/bin/python':
                    ensure  => link,
                    target  => '/tools/python27/bin/python2.7',
                    require => Class[ 'dirs::tools::buildbot::bin',
                                      'packages::mozilla::python27' ];
                '/tools/misc-python/virtualenv.py':
                    ensure  => link,
                    target  => '/tools/virtualenv/bin/virtualenv',
                    require => Class[ 'dirs::tools::misc_python',
                                      'packages::mozilla::py27_virtualenv' ];
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
        class {
            'slave_secrets':
                slave_type => 'test';
        }
    }
}
