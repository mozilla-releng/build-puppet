class mozpool::config {
    include config::secrets
    include mozpool::settings

    file {
        $mozpool::settings::config_ini:
            content => template("mozpool/config.ini.erb"),
            mode => 0755;
    }

}
