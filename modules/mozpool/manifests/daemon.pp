class mozpool::daemon {
    include mozpool::settings
    include mozpool::virtualenv

    # run the daemon on port 8010; Apache will proxy there
    supervisord::supervise {
      "bmm-server":
         command => "${::mozpool::settings::root}/frontend/bin/mozpool-server 8010",
         user => 'apache',
         environment => [ "BMM_CONFIG=${::mozpool::settings::config_ini}" ],
         require => Class['mozpool::virtualenv'];
    }
}
