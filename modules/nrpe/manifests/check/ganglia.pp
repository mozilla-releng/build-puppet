class nrpe::check::ganglia {
    include nrpe::settings
    $plugins_dir = $nrpe::settings::plugins_dir

    nrpe::check {
        'check_ganglia':
            cfg => "$plugins_dir/check_ganglia -h \$ARG1\$ -s \$ARG2\$ -m \$ARG3\$ -w \$ARG4\$ -c \$ARG5\$";
    }

    nrpe::plugin {
        "check_ganglia": ;
    }
}
