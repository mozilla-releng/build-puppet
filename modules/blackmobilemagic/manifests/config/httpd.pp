class blackmobilemagic::config::httpd {
    include httpd

    httpd::config {
        "bmm_httpd.conf" :
            contents => template("blackmobilemagic/bmm_httpd.conf.erb");
    }

    file {
       "/opt/bmm/www":
            ensure => directory;
        "/opt/bmm/www/scripts":
            ensure => directory;
        "/opt/bmm/www/scripts/second-stage.sh":
            ensure => file,
            content => template("blackmobilemagic/second-stage.sh.erb");
        "/opt/bmm/www/squashfs":
            recurse => true,
            purge => true,
            source => [ "puppet:///bmm/squashfs", "puppet:///bmm/private/squashfs" ],
            sourceselect => all,
            ensure => directory;
       "/opt/bmm/www/artifacts":
            recurse => true,
            purge => true,
            source => [ "puppet:///bmm/artifacts", "puppet:///bmm/private/artifacts" ],
            sourceselect => all,
            ensure => directory;
   }
}

