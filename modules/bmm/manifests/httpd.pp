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

    bmm::script {
        "liveutil.sh": ;
        "android-second-stage.sh": ;
        "b2g-second-stage.sh": ;
        "maintenance-second-stage.sh": ;
    }
}

