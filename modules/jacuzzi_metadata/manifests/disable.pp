class jacuzzi_metadata::disable {
    file {
        "/etc/init.d/jacuzzi_metadata":
            ensure => absent;
        "/etc/jacuzzi_metadata.json":
            ensure => absent;
        "/usr/local/bin/jacuzzi_metadata.py":
            ensure => absent;
    }
    case $::operatingsystem {
        Ubuntu, CentOS: {
            service {
                "jacuzzi_metadata":
                    ensure => stopped,
                    enable => false;
            }
        }
    }
}
