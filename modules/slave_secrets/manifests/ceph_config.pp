# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class slave_secrets::ceph_config($ensure=present) {
    include config
    include users::builder

    if ($ensure == 'present' and $config::install_ceph_cfg) {
        if ($config::node_location == 'in-house' and $slave_trustlevel == 'try') {
            $boto_content = template("$module_name/try_dot_boto.erb")
        } else {
            # We need an empty .boto in this case because buildbot will copy it
            # into the mock environment regardless, and fails if the file is
            # not present.
            $boto_content = ""
        }
        file {
            "${users::builder::home}/.boto":
                mode      => 0600,
                owner     => "${users::builder::username}",
                group     => "${users::builder::group}",
                show_diff => false,
                content   => $boto_content,
        }
    } else {
        file {
            "${users::builder::home}/.boto":
                ensure => absent;
        }
    }
}
