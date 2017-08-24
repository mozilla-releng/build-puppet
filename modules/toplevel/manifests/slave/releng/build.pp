# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class toplevel::slave::releng::build inherits toplevel::slave::releng {
    include dirs::tools
    include dirs::builds
    include dirs::builds::slave
    include dirs::builds::hg_shared
    include dirs::builds::git_shared
    include dirs::builds::tooltool_cache

    include users::builder

    if ($::operatingsystem == Windows) {
        include tweaks::vs_2013_lnk
        include tweaks::windows_sendchange_hack
        include tweaks::disablejit
        include tweaks::shutdown_tracker
        include packages::binscope
    }

    if ($::operatingsystem != Windows) {
        include ntp::daemon
        include tweaks::nofile
        include tweaks::filesystem
    }

    include nrpe
    include nrpe::check::buildbot
    if ($::operatingsystem != Windows) {
        include nrpe::check::ide_smart
        include nrpe::check::procs_regex
        include nrpe::check::child_procs_regex
    }

    include packages::mozilla::git
    include packages::mozilla::hgtool
    include packages::mozilla::gittool
    include packages::mozilla::retry
    include packages::patch

    include runner::tasks::clobber

    # The runner purge_build target for Windows is set to 35 GB
    # This is to ensure there is enough space for PGO builds
    # Ref: https://bugzilla.mozilla.org/show_bug.cgi?id=1227390
    if ($::operatingsystem == Windows) {
        class {
            'runner::tasks::purge_builds':
                required_space => 35;
        }
        include runner::tasks::check_ami
    }

    if ($::operatingsystem != Windows) {
        include packages::mozilla::py27_virtualenv

        include jacuzzi_metadata::disable
        include aws::instance_storage

        ccache::ccache_dir {
            '/builds/ccache':
                maxsize => '10G',
                owner   => $users::builder::username,
                group   => $users::builder::group;
        }

        include runner::tasks::checkout_tools
        include runner::tasks::update_shared_repos
        include runner::tasks::cleanup
        include runner::tasks::config_hgrc
        class {
            'runner::tasks::purge_builds':
                required_space => 20;
        }
    }

    class {
        'slave_secrets':
            slave_type => 'build';
    }
}
