# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class slave_secrets::ceph_config($ensure=present) {
    include config
    include users::builder

    if ($ensure == 'present' and $config::install_ceph_cfg) {
        if ($::config::node_location == 'in-house' and $slave_trustlevel == 'try') {
            $boto_content = template("${module_name}/try_dot_boto.erb")
        } elsif ($::config::node_location == 'aws') {
            $boto_content = template("${module_name}/aws_dot_boto.erb")
        } else {
            # We need an empty .boto in this case because buildbot will copy it
            # into the mock environment regardless, and fails if the file is
            # not present.
            $boto_content = ''
        }
        case $::operatingsystem {
            Windows: {
                file {
                    "${users::builder::home}/.boto":
                        content   => $boto_content,
                        show_diff => false;
                }
                acl {
                    "${users::builder::home}/.boto":
                        purge                      => true,
                        inherit_parent_permissions => false,
                        # indentation of => is not properly aligned in hash within array: The solution was provided on comment 2
                        # https://github.com/rodjek/puppet-lint/issues/333
                        permissions                => [
                            {
                              identity => 'root',
                              rights   => ['full'] },
                            {
                              identity => 'SYSTEM',
                              rights   => ['full'] },
                            {
                              identity => 'cltbld',
                              rights   => ['full'] },
                        ];
                }
            }
            default: {
                file {
                    "${users::builder::home}/.boto":
                        mode      => '0600',
                        owner     => $users::builder::username,
                        group     => $users::builder::group,
                        show_diff => false,
                        content   => $boto_content,
                }
            }
    }
    } else {
        file {
            "${users::builder::home}/.boto":
                ensure => absent;
        }
    }
}
