class blackmobilemagic::config::httpd {
    include blackmobilemagic::settings
    include ::httpd

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
        "/opt/bmm/www/scripts/maintenance-second-stage.sh":
            ensure => file,
            content => template("blackmobilemagic/maintenance-second-stage.sh.erb");
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

        # /frontend runs the frontend CGI
        "/opt/bmm/www/frontend":
            recurse => true,
            purge => true,
            ensure => directory;
        "/opt/bmm/www/frontend/index.cgi":
            ensure => link,
            target => "/opt/bmm/frontend/bin/bmm-server";
   }
}

