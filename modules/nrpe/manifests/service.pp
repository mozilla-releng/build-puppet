class nrpe::service {
    include nrpe::install

    service {
        "nrpe":
            enable => "true",
            ensure => "running",
            require => Class['nrpe::install'];
    }
}
