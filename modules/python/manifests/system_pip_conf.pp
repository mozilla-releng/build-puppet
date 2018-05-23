# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class python::system_pip_conf {
    include config

    # for the template
    $user_python_repositories = $config::user_python_repositories
    case $::operatingsystem {
        "CentOS": {
            $filename = "/etc/pip.conf"
            $user     = "root"
            $group    = "root"
        }
        "Ubuntu": {
            $filename = "/etc/pip.conf"
            $user     = "root"
            $group    = "root"
        }
        "Darwin": {
            $filename = "/Library/Application Support/pip/pip.conf"
            $user     = "root"
            $group    = "wheel"
        }
        "windows": {
            $filename = $::operatingsystemrelease ? {
                XP => "C:\\Documents and Settings\\All Users\\Application Data\\pip\\pip.ini",
                default => "C:\\ProgramData\\pip\\pip.ini",
            }
            $user     = "administrator"
            $group    = "administrator"
        }
        default: {
            fail("This OS is not supported for system_pip_conf")
        }
    }
    if $filename {
        file {
            "${filename}":
                content => template("python/user-pip-conf.erb"),
                owner   => $user,
                group   => $group,
                mode    => "0755";
        }
    }
}
