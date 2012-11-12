class bmm::httpd {
    include ::httpd

    httpd::config {
        "bmm_httpd.conf" :
            contents => template("bmm/bmm_httpd.conf.erb");
    }

    file {
       "/opt/bmm/www":
            ensure => directory;
        "/opt/bmm/www/scripts":
            ensure => directory;
        "/opt/bmm/www/scripts/liveutil.sh":
            ensure => file,
            content => template("bmm/liveutil.sh.erb");
        "/opt/bmm/www/scripts/android-second-stage.sh":
            ensure => file,
            content => template("bmm/android-second-stage.sh.erb");
        "/opt/bmm/www/scripts/maintenance-second-stage.sh":
            ensure => file,
            content => template("bmm/maintenance-second-stage.sh.erb");
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

