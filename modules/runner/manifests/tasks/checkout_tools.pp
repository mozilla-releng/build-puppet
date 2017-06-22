# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class runner::tasks::checkout_tools($runlevel=0) {
    include packages::mozilla::hgtool
    include runner

    file {
        '/tools/checkouts':
            ensure => directory,
            owner  => $::config::builder_username,
            group  => $::config::builder_group;
    }
    runner::task {
        "${runlevel}-checkout_tools":
            require => [
                Class['packages::mozilla::hgtool'],
                File['/tools/checkouts'],
            ],
            content => template("${module_name}/tasks/checkout_tools.erb");
    }
}
