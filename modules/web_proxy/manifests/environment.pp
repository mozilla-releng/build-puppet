# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class web_proxy::environment {
    if $web_proxy::host != '' {
        case $::operatingsystem {
            Darwin,
            CentOS,
            Ubuntu: {
                shellprofile::file { 'proxy':
                    ensure  => present,
                    content => template("${module_name}/environment.erb")
                }

            }
            default: {
                fail("${module_name} does not support ${::operatingsystem}")
            }
        }
    }

    # Puppet agent will not be able to install packages from repo if a proxy is
    # set.  Source this script for all commands, which require no proxy being
    # set.  Note that this file must exist unconditionally, as the puppet scripts
    # use it and will fail if it is missing.
    if ($::operatingsystem != 'windows') {
        include ::dirs::usr::local::bin
        file { 'proxy_reset_environment':
            ensure => present,
            path   => '/usr/local/bin/proxy_reset_env.sh',
            mode   => '0755',
            source => 'puppet:///modules/web_proxy/unix_proxy_reset_env.sh'
        }
    }
}
