# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class ssh::config {
    include users::root
    include ssh::settings
    include ssh::service

    case $::operatingsystem {
        CentOS: {
            # enable sftp sybsystem on CentOS
            $sftp_line = "Subsystem sftp /usr/libexec/openssh/sftp-server"
        }
    }

    file {
        $ssh::settings::ssh_config:
            owner => $users::root::username,
            group => $users::root::group,
            mode => 0644,
            content => template("${module_name}/ssh_config.erb");
        $ssh::settings::sshd_config:
            owner => $::users::root::username,
            group => $::users::root::group,
            mode => 0644,
            notify => Class['ssh::service'], # restart daemon if necessary
            content => template("${module_name}/sshd_config.erb");
        $ssh::settings::known_hosts:
            owner => $::users::root::username,
            group => $::users::root::group,
            mode => 0644,
            content => template("${module_name}/known_hosts.erb");
    }
}
