class nrpe::check::child_procs_regex {
    include nrpe::settings
    $plugins_dir = $nrpe::settings::plugins_dir

    nrpe::check {
        'check_child_procs_regex':
            cfg => "$plugins_dir/check_procs -c \$ARG3\$:\$ARG4\$ --ereg-argument-array=\$ARG1\$ -p \$ARG2\$";
    }
}
