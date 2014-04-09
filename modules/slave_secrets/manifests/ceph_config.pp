# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class slave_secrets::ceph_config($ensure=present) {
    include users::builder

    if ($ensure == 'present') {
        file {
            "${users::builder::home}/.boto":
                mode      => 0600,
                owner     => "${users::builder::username}",
                group     => "${users::builder::group}",
                show_diff => false,
                content   => template("$module_name/dot_boto.erb"),
        }
    } else {
        file {
            "${users::builder::home}/.boto":
                ensure => absent;
        }
    }
}
