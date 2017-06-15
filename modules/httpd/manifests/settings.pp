# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class httpd::settings {
    include ::shared
    include users::root
    $group = $users::root::group
    $owner = $users::root::username
    $mode = '0644'
    case $::operatingsystem {
        CentOS: {
            $conf_d_dir = '/etc/httpd/conf.d'
        }
        Ubuntu: {
            $conf_d_dir = '/etc/apache2/sites-enabled'
        }
        Darwin: {
            $conf_d_dir = '/etc/apache2/other'
        }
        default: {
            fail("Don't know how to set up Apache on ${::operatingsystem}")
        }
    }
}
