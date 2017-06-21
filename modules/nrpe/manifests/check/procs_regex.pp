# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class nrpe::check::procs_regex {
    include nrpe::settings
    $plugins_dir = $nrpe::settings::plugins_dir

    nrpe::check {
        'check_procs_regex':
            cfg => "${plugins_dir}/check_procs -c \$ARG2\$:\$ARG3\$ --ereg-argument-array=\$ARG1\$";
    }
}
