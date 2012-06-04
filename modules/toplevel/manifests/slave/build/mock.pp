class toplevel::slave::build::mock inherits toplevel::slave::build {
    include ::config
    include packages::mozilla::mock_mozilla

    # Add builder_username to the mock_mozilla group, so that it can use the
    # utility.  This could be done via the User resource type, but there's no
    # good way to communicate the need to that class.
    exec {
        'add-builder-to-mock_mozilla':
            command => "/usr/bin/gpasswd -a $::config::builder_username mock_mozilla",
            unless => "/usr/bin/groups $::config::builder_username | grep '\\<mock_mozilla\\>'",
            require => Class['packages::mozilla::mock_mozilla'];
    }
}
