class users::global {
    # add some custom stuff to $PATH; some of these may not exist everywhere,
    # but this doesn't hurt.
    $path_additions = [
        '/tools/git/bin/',
        '/tools/python27/bin/',
        '/tools/python27-mercurial/bin',
    ]
    file {
        "/etc/profile.d/releng-path.sh":
            ensure => file,
            mode => 444,
            owner => root,
            group => root,
            content => template("users/releng-path.erb");
    }

    # put some basic information in /etc/motd
    file {
        "/etc/motd":
            mode => 644,
            owner => root,
            group => root,
            content => inline_template("This is <%= fqdn %> (<%= ipaddress %>)");
    }
}
