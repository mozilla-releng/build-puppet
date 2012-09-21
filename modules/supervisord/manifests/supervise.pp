define supervisord::supervise($command, $user, $autostart=true, $autorestart=true) {
    include supervisord::base

    file {
        "/etc/supervisord.conf.d/$name":
            content => template("supervisord/snippet.erb"),
            notify => Service["supervisord"];
    }
}
