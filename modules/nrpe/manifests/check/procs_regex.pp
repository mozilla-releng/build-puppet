class nrpe::check::procs_regex {
    include nrpe::settings
    $plugins_dir = $nrpe::settings::plugins_dir

    nrpe::check {
        'check_procs_regex':
            cfg => "$plugins_dir/check_procs -c \$ARG2\$:\$ARG3\$ --ereg-argument-array=\$ARG1\$";
    }
}
