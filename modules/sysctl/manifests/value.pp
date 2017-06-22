# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define sysctl::value(
    $value
){

    exec { "exec_sysctl_${name}":
        command     => "/sbin/sysctl ${name}='${value}'",
        refreshonly => true,
    }

    sysctl { $name:
        val    => $value,
        notify => Exec["exec_sysctl_${name}"],
    }
}
