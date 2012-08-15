class puppetmaster::config {
    include packages::httpd

    file {
        "/etc/puppet/fileserver.conf":
            mode => 0644,
            owner => root,
            group => root,
            require => Class["puppet"],
            source => "puppet:///modules/puppetmaster/fileserver.conf";
        "/etc/httpd/conf.d/yum_mirrors.conf":
            require => Class["packages::httpd"],
            source => "puppet:///modules/puppetmaster/yum_mirrors.conf";
        "/etc/httpd/conf.d/puppetmaster_passenger.conf":
            require => Class["packages::httpd"],
            content => template("puppetmaster/puppetmaster_passenger.conf.erb");
        ["/etc/puppet/rack", "/etc/puppet/rack/public"]:
            require => Class["puppet"],
            ensure => directory,
            owner  => puppet,
            group  => puppet;
         "/var/lib/puppet/reports":
            require => Class["puppet"],
            ensure => directory,
            mode => 750,
            recurse => true,
            owner  => puppet,
            group  => puppet;
        "/etc/puppet/rack/config.ru":
            owner  => puppet,
            group  => puppet,
            source => "puppet:///modules/puppetmaster/config.ru";
    }
}
