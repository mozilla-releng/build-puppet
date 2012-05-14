class nrpe::check::ntp_time {
    include nrpe::settings
    $plugins_dir = $nrpe::settings::plugins_dir

    nrpe::check {
        'check_ntp_time':
            cfg => "$plugins_dir/check_ntp_time -H \$ARG1\$ -w \$ARG2\$ -c \$ARG3\$";
    }
}
