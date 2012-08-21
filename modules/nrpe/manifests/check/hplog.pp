class nrpe::check::hplog {
    include nrpe::settings
    $plugins_dir = $nrpe::settings::plugins_dir

    nrpe::check {
        'check_hplog':
            cfg => "$plugins_dir/check_hplog -t l";
    }

    nrpe::plugin {
        'check_hplog': ;
    }

    sudoers::custom {
        'check_hplog':
            user => 'nagios',
            command => "/sbin/hplog";
    }
}
