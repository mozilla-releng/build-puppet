# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class nrpe::check::check_stop_idle {
    include nrpe::settings
    include aws_manager::settings
    $plugins_dir = $nrpe::settings::plugins_dir

    nrpe::check {
        'check_stop_idle':
            cfg => "${plugins_dir}/check_file_age -w 600 -c 1800 -f ${aws_manager::settings::root}/aws_stop_idle.log";
    }
}
