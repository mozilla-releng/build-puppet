class dirs::builds::slave {
    include dirs::builds
    include shared::builder
    include config
   
    file {
            "/builds/slave" :
            ensure => directory,
            owner => "$config::builder_username",
            group => "$shared::builder::group",
            mode => 0755;
    }
}


