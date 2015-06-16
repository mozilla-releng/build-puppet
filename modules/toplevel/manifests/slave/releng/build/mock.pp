# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class toplevel::slave::releng::build::mock inherits toplevel::slave::releng::build {
    include ::config
    include mockbuild
    include users::builder
    include packages::gdb
    # php and svn are needed to run the postrelease builder, bug 1062897
    include packages::php
    include packages::subversion

    if $::virtual == 'xenhvm' {
        # Bug 964880: make sure to enable swap on some instance types
        include tweaks::swap_on_instance_storage
    }

    # Add builder_username to the mock_mozilla group, so that it can use the
    # utility.  This could be done via the User resource type, but there's no
    # good way to communicate the need to that class.
    exec {
        'add-builder-to-mock_mozilla':
            command => "/usr/bin/gpasswd -a ${users::builder::username} mock_mozilla",
            unless  => "/usr/bin/groups ${users::builder::username} | grep '\\<mock_mozilla\\>'",
            require => [Class['packages::mozilla::mock_mozilla'], Class['users::builder']];
    }

    include runner::tasks::config_mockbuild
    case $::kernel {
        'Linux': {
            include runner::tasks::populate_shared_repos
            include runner::tasks::check_ami
        }
    }
}
