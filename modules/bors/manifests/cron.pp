define bors::cron($basedir, $owner) {
    include packages::procmail # for lockfile

    file {
        "/etc/cron.d/bors-${title}":
            mode => 600,
            content => template("bors/bors-cron.erb");
    }
}
