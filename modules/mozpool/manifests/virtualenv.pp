class mozpool::virtualenv {
    include packages::mozilla::python27
    include mozpool::settings
    include config::secrets

    python::virtualenv {
        "$mozpool::settings::root/frontend":
            python => "/tools/python27/bin/python2.7",
            require => Class['packages::mozilla::python27'],
            packages => [
                "argparse==1.1",
                "SQLAlchemy==0.7.9",
                "web.py==0.37",
                "requests==0.14.1",
                "lockfile==0.9.1",
                "python-daemon==1.5.5",
                "which==1.1.0",
                "Tempita==0.5.1",
                'templeton==0.6.2',
                "flup==1.0.3.dev-20110405",
                "pymysql==0.5",
                "mozpool==0.5.6",
            ],
            notify => Service['supervisord'];
    }

    # add the virtualenv's bin/ to the global PATH
    shellprofile::file {
        "mozpool_path":
            content => "export PATH=\$PATH:${mozpool::settings::root}/frontend/bin";
    }
}

