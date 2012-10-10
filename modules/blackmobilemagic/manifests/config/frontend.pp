class blackmobilemagic::config::frontend {
    include dirs::opt::bmm
    include packages::mozilla::python27
    include blackmobilemagic::settings
    include config::secrets

    python::virtualenv {
        "/opt/bmm/frontend":
            python => "/tools/python27/bin/python2.7",
            require => Class['packages::mozilla::python27'],
            packages => [
                "SQLAlchemy==0.7.9",
                "web.py==0.37",
                "requests==0.14.1",
                "lockfile==0.9.1",
                "python-daemon==1.5.5",
                "which==1.1.0",
                "Tempita==0.5.1",
                # templeton?! (currently hand-installed; mcote will do a 0.6 release 10/10/2012
                "flup==1.0.3.dev-20110405",
                "blackmobilemagic==0.1.0",
            ];
    }

    file {
        $blackmobilemagic::settings::config_ini:
            content => template("blackmobilemagic/config.ini"),
            mode => 0755;
    }

    # only the admin node should do the inventory sync
    if ($is_bmm_admin_host) {
        notice("hi")
        file {
            "/etc/cron.d/bmm-inventorysync":
                content => "15,45 * * * * apache BMM_CONFIG=${::blackmobilemagic::settings::config_ini} /opt/bmm/frontend/bin/bmm-inventorysync";
        }
    } else {
        file {
            "/etc/cron.d/bmm-inventorysync":
                ensure => absent;
        }
    }
}
