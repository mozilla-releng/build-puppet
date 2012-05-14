class nrpe::check::http_redirect_ip {
    include nrpe::settings
    $plugins_dir = $nrpe::settings::plugins_dir

    nrpe::check {
        'check_http_redirect_ip':
            cfg => "$plugins_dir/check_http_redirect_ip -U \$ARG1\$ -I \$ARG2\$";
    }

    nrpe::plugin {
        "check_http_redirect_ip": ;
    }
}
