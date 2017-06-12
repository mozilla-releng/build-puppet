# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class web_proxy::gui {
    case $::operatingsystem {
        Darwin: {
            include ::dirs::usr::local::bin
            file {
                '/usr/local/bin/setproxy.sh' :
                    ensure  => present,
                    owner   => $users::root::username,
                    group   => $users::root::group,
                    mode    => '0755',
                    content => template("${module_name}/gui_darwin.erb"),
                    notify  => Exec['set-proxy-gui'] ;
            }

            exec {
                'set-proxy-gui' :
                    command     => '/usr/local/bin/setproxy.sh',
                    refreshonly => true;
            }
        }
    }
}
