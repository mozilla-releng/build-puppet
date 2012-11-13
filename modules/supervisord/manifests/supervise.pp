define supervisord::supervise($command, $user, $autostart=true, $autorestart=true, $environment=[], $extra_config='') {
    include supervisord::base

    file {
        "/etc/supervisord.d/$name":
            content => template("supervisord/snippet.erb"),
            notify => Service["supervisord"];
    }
}
