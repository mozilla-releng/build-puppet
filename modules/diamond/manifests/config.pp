# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class diamond::config {
    include users::root
    include diamond::settings
    include diamond::service
    include packages::diamond

    case $::operatingsystem {
        CentOS: {
            file {
                $diamond::settings::diamond_config:
                    require => Class['packages::diamond'],
                    owner => $::users::root::username,
                    group => $::users::root::group,
                    mode => 0644,
                    notify => Class['diamond::service'], # restart daemon if necessary
                    content => template("${module_name}/diamond_config.erb");
            }
        }
        default: {
            fail("Don't know how to configure Diamond on this platform")
        }
    }
}
