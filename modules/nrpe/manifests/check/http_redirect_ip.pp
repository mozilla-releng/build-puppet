# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class nrpe::check::http_redirect_ip {
    include nrpe::settings
    $plugins_dir = $nrpe::settings::plugins_dir

    nrpe::check {
        'check_http_redirect_ip':
            cfg => "${plugins_dir}/check_http_redirect_ip -U \$ARG1\$ -I \$ARG2\$";
    }

    nrpe::plugin {
        'check_http_redirect_ip': ;
    }
}
