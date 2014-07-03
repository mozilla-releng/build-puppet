class kernelmodule::rc_modules {
    file {
        "/etc/rc.modules":
            ensure => present,
            mode => 0755;
    }
}
