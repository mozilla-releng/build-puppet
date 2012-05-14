class nrpe::check::ide_smart {
    include nrpe::settings
    $plugins_dir = $nrpe::settings::plugins_dir

    nrpe::check {
        'check_ide_smart':
            cfg => "sudo $plugins_dir/check_ide_smart -n -d \$ARG1\$";
    }

    sudoers::custom {
        'check_ide_smart':
            user => 'nagios',
            command => "$plugins_dir/check_ide_smart";
    }
}
