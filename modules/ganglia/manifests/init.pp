class ganglia {
    include ::config
    if $::config::ganglia_config_class == "" {
        # No Ganglia Config defined, don't install
    } else {
        include packages::ganglia
        include shared

        class {
            $::config::ganglia_config_class:
                ;
        }
        
        file {
            "/etc/ganglia":
                ensure => directory,
                owner => "root",
                group => "$::shared::root_group",
                mode => 644;
        }
        
        service {
            gmond:
                require => File["/etc/ganglia/gmond.conf"],
                enable => true,
                ensure => running;
        }
    }
}