# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class nrpe::check::ganglia {
    include nrpe::settings
    $plugins_dir = $nrpe::settings::plugins_dir

    nrpe::check {
        'check_ganglia':
            cfg => "$plugins_dir/check_ganglia -h \$ARG1\$ -s \$ARG2\$ -m \$ARG3\$ -w \$ARG4\$ -c \$ARG5\$";
    }

    nrpe::plugin {
        "check_ganglia": ;
    }
}
