class l10n_bumper::services {
    include ::config
    include users::builder
    include l10n_bumper::settings
    include packages::mozilla::python27
    include packages::procmail # for lockfile

    $env_config = $config::l10n_bumper_env_config[$l10n_bumper_env]

    $owner = $users::builder::username
    $basedir = $l10n_bumper::settings::root
    $python = $packages::mozilla::python27::python
    $mailto = $l10n_bumper::settings::mailto
    $config_file = $env_config['config_file']
    file {
        "/etc/cron.d/l10n_bumper":
            require => File["${basedir}/download_mozharness.sh"],
            mode => 600,
            content => template("l10n_bumper/cron.erb");
    }
}
