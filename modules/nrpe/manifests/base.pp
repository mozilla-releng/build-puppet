class nrpe::base {
    include nrpe::settings
    include nrpe::install
    include nrpe::service
    include config # for vars for templates

    $plugins_dir = $nrpe::settings::plugins_dir

    # configure
    file {
        "/etc/nagios/nrpe.cfg":
            content => template("nrpe/nrpe.cfg.erb"),
            owner   => "root",
            group   => "root",
            require => Package["nrpe"],
            notify => Class['nrpe::service'];
        "/etc/nagios/nrpe.d":
            ensure => directory,
            owner  => "root",
            group  => "root",
            recurse => true,
            purge => true,
            require => Package["nrpe"],
            notify => Class['nrpe::service'];
    }
}
