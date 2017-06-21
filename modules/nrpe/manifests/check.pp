# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# used from nrpe::check::*; do not use directly
define nrpe::check($cfg=undef, $nsclient_cfg=undef) {
    include nrpe::base
    include nrpe::settings
    include users::root

    case $::operatingsystem {
        Windows: {
            concat::fragment { 'nsc_ini_check':
                target  => 'c:\program files\nsclient++\nsc.ini',
                content => $nsclient_cfg,
                order   => '02',
            }
        }
        default: {
            file {
                "${nrpe::settings::nrpe_etcdir}/nrpe.d/${title}.cfg":
                    owner   => $::users::root::username,
                    group   => $::users::root::group,
                    notify  => Class['nrpe::service'],
                    content => "command[${title}]=${cfg}\n";
            }
        }
    }
}
