# used from nrpe::check::*; do not use directly
define nrpe::plugin {
    include nrpe::base
    include nrpe::settings

    file {
        "$nrpe::settings::plugins_dir/$title":
            owner => root,
            group => root,
            mode => 0755,
            require => Class['nrpe::install'],
            source => "puppet:///nrpe/$title";
    }
}
