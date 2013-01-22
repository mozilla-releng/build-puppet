class buildslave::startup::desktop {
    include users::builder
    include packages::mozilla::python27

    file {
        ["${::users::builder::home}/.config",
         "${::users::builder::home}/.config/autostart"]:
            ensure => directory,
            owner  => $users::builder::username,
            group  => $users::builder::group;
        "${::users::builder::home}/.config/autostart/gnome-terminal.desktop":
            require => File["/usr/local/bin/runslave.py"],
            content => template("buildslave/gnome-terminal.desktop.erb"),
            owner   => $users::builder::username,
            group   => $users::builder::group;
    }
}
