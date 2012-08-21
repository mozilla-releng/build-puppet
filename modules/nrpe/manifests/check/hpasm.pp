class nrpe::check::hpasm {
    include nrpe::settings
    $plugins_dir = $nrpe::settings::plugins_dir

    nrpe::check {
        'check_hpasm':
            cfg => "$plugins_dir/check_hpasm -t 20";
    }

    nrpe::plugin {
        'check_hpasm': ;
    }

    sudoers::custom {
        'check_hpasm':
            user => 'nagios',
            command => "/sbin/hpasmcli";
    }
}
