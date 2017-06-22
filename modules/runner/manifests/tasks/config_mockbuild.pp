# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Make sure runner runs at boot
class runner::tasks::config_mockbuild($runlevel=3) {
    include runner

    file {
        '/etc/mock_mozilla':
            ensure  => directory;
        '/etc/mock_mozilla/config-templates':
            source  => 'puppet:///modules/runner/mockbuild-config-templates',
            recurse => true,
            force   => true;
    }

    runner::task {
        "${runlevel}-config_mockbuild":
            content => template("${module_name}/tasks/config_mockbuild.erb"),
            require => File['/etc/mock_mozilla/config-templates'];
    }
}
