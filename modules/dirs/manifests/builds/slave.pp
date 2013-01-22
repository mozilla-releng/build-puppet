class dirs::builds::slave {
    include dirs::builds
    include users::builder
    include config

    file {
            "/builds/slave" :
            ensure => directory,
            owner => "$users::builder::username",
            group => "$users::builder::group",
            mode => 0755;
    }
}


