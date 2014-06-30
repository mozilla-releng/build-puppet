# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class web_proxy::environment {
    if $web_proxy::host != "" {
        case $operatingsystem {
            Darwin,
            CentOS,
            Ubuntu: {
                shellprofile::file { "proxy":
                    ensure => present,
                    content => template("${module_name}/environment.erb")
                }
            }
            default: {
                fail("${module_name} does not support ${operatingsystem}")
            }
        }
    } else {
        # Ensure the proxy settings are removed if none are set
        case $operatingsystem {
            Darwin,
            CentOS,
            Ubuntu: {
                shellprofile::file { "proxy":
                    ensure => absent
                }
            }
        }
    }

    # Environment vars for proxies is set via /etc/profile.puppet.d/proxy.sh now.
    # Remove that section once all CentOS systems have been updated.
    case $operatingsystem {
       CentOS: {
           file { "/etc/environment":
               content => "",
            }
        }
    }
}
