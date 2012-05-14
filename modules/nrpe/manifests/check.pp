# used from nrpe::check::*; do not use directly
define nrpe::check($cfg) {
    include nrpe::base

    file {
        "/etc/nagios/nrpe.d/$title.cfg":
            owner => root,
            group => root,
            notify => Class['nrpe::service'],
            content => "command[$title]=$cfg\n";
    }
}

