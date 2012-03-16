class dirs::builds::slave {
    include dirs::builds

    file {
        "/builds/slave":
            ensure => directory,
            owner => "$config::builder_username",
            group => "$config::builder_username",
            mode => 0755;
    }
}

