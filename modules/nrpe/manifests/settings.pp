class nrpe::settings {
    $plugins_dir = $hardwaremodel ? {
        i686   => "/usr/lib/nagios/plugins",
        x86_64 => "/usr/lib64/nagios/plugins",
    }
}
