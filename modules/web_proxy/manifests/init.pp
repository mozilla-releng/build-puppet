# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class web_proxy {
    include config
    if ($::config::web_proxy_url != '') {
        $web_proxy_url = $::config::web_proxy_url
        $web_proxy_exceptions = $::config::web_proxy_exceptions
        case $operatingsystem {
            CentOS: {
                file {
                    "/etc/environment":
                        content => template("${module_name}/environment.erb");
                }
            }
            default: {
                fail("${module_name} does not support ${operatingsystem}")
            }
        }
    } else {
        # ensure the corresponding files are blank
        case $operatingsystem {
            CentOS: {
                file {
                    "/etc/environment":
                        content => "";
                }
            }
        }
    }
}
