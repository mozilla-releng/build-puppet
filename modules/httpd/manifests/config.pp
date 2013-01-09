# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define httpd::config ($file = $title, $contents = '') {
    include httpd
    include packages::httpd
    include httpd::settings
    case $::operatingsystem {
        Darwin, CentOS, Ubuntu: {
            if ($file != undef) and ($contents != undef) {
                file {
                    "$file" :
                        require => Class['packages::httpd'],
                        notify => $httpd::settings::service_class,
                        path => "$httpd::settings::conf_d_dir/$file",
                        mode => "$httpd::settings::mode",
                        owner => "$httpd::settings::owner",
                        group => "$httpd::settings::group",
                        content => $contents;
                }
            }
        }
        default: {
            fail("Don't know how to set up httpd::config on $::operatingsystem")
        }
    }
}
