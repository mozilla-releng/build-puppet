class mozpool::config {
    include config::secrets
    include mozpool::settings

    file {
        $mozpool::settings::config_ini:
            content => template("mozpool/config.ini.erb"),
            mode => 0755;
    }

    # put that in an env var in the global profile
    shellprofile::file {
        "mozpool_config":
            content => "export MOZPOOL_CONFIG=$mozpool::settings::config_ini";
    }
}
