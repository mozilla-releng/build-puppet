class nrpe::check::swap {
    include nrpe::settings
    $plugins_dir = $nrpe::settings::plugins_dir

    nrpe::check {
        'check_swap':
            cfg => "$plugins_dir/check_swap -w \$ARG1\$ -c \$ARG2\$";
    }
}
