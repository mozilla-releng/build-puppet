# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# used from nrpe::check::*; do not use directly
define nrpe::plugin {
    include nrpe::base
    include nrpe::settings

    if $title != undef {
        if $title =~ /(^.+)\.erb$/ {
            $script_name = $1
            $script_source = 'template'
        } else {
            $script_name = $title
            $script_source = 'file'
        }

        $script_path = "${nrpe::settings::plugins_dir}/${script_name}"

        file {
            $script_path:
                ensure  => present,
                owner   => $::users::root::username,
                group   => $::users::root::group,
                mode    => '0755',
                require => Class['nrpe::base'],
        }
        case $script_source {
            'file': {
                File[$script_path] {
                    source => "puppet:///modules/nrpe/${script_name}"
                }
            }
            'template': {
                File[$script_path] {
                    content => template("nrpe/${script_name}.erb")
                }
            }
        }
    }
}
