# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class nrpe::check::ntp_peer {
    include nrpe::settings
    $plugins_dir = $nrpe::settings::plugins_dir

    nrpe::check {
        'check_ntp_peer':
            cfg => "${plugins_dir}/check_ntp_peer -H localhost -w \$ARG1\$ -c \$ARG2\$";
    }
}
