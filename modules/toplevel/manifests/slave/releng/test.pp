# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class toplevel::slave::releng::test inherits toplevel::slave::releng {
    include talos
    include vnc
    include users::builder::autologin
    include ntp::atboot
    include packages::fonts
    include packages::unzip
    include tweaks::fonts
    include runner::tasks::cleanup
    include dirs::builds::hg_shared
    include dirs::builds::git_shared
    include dirs::builds::tooltool_cache

    case $::operatingsystem {
        "Ubuntu": {
            include runner::tasks::update_shared_repos
            include runner::tasks::checkout_tools
            include runner::tasks::restart_services
            include runner::tasks::check_ami
            class {
                'runner::tasks::purge_builds':
                    required_space => 4;
            }
         }
        "Darwin": {
            include runner::tasks::update_shared_repos
            include runner::tasks::checkout_tools
            class {
                'runner::tasks::purge_builds':
                    required_space => 4;
            }
         }
    }

    include runner::tasks::config_hgrc

    class {
        'slave_secrets':
            slave_type => 'test';
    }
}
