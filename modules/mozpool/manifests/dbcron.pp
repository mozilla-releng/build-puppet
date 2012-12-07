class mozpool::dbcron {
    $dbcron_sh = "/opt/mozpool/dbcron.sh"
    file {
        $dbcron_sh:
            content => template("mozpool/dbcron.sh.erb"),
            mode => 0755;
    }
    if ($is_bmm_admin_host) {
        file {
            "/etc/cron.d/mozpool-dbcron":
                # run once a day
                content => "0 0 * * * apache $dbcron_sh\n";
        }
    } else {
        file {
            "/etc/cron.d/mozpool-dbcron":
                ensure => absent;
        }
    }
}
