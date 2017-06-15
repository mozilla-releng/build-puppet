# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class funsize_scheduler::conf {
    include ::config
    include funsize_scheduler::settings
    include dirs::builds
    include users::builder

    file {
        "${funsize_scheduler::settings::root}/config.yml":
            require   => Python::Virtualenv[$funsize_scheduler::settings::root],
            mode      => '0600',
            owner     => $users::builder::username,
            group     => $users::builder::group,
            content   => template("${module_name}/config.yml.erb"),
            show_diff => false;
        "${funsize_scheduler::settings::root}/id_rsa":
            require   => Python::Virtualenv[$funsize_scheduler::settings::root],
            mode      => '0600',
            owner     => $users::builder::username,
            group     => $users::builder::group,
            content   => secret('funsize_signing_pvt_key'),
            show_diff => false;
    }
}
