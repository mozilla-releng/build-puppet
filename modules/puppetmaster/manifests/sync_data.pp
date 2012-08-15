class puppetmaster::sync_data {
    file {
        "/etc/cron.d/sync_data.cron":
            content => "15 * * * * root  rsync -a --exclude=lost+found --delete rsync://puppetagain.pub.build.mozilla.org/data/ /data/\n";
    }
}
