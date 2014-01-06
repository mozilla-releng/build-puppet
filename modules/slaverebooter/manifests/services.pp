class slaverebooter::services {
    include ::config
    include users::builder
    include slaverebooter::settings
    include packages::procmail # for lockfile

    $owner = $users::builder::username
    $basedir = $slaverebooter::settings::root
    $config = $slaverebooter::settings::config
    file {
        "/etc/cron.d/slaverebooter":
            require => Python::Virtualenv["${basedir}"],
            mode => 600,
            content => template("slaverebooter/cron.erb");
    }
}
