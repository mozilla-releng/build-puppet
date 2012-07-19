class dirs::usr::local::bin {
    include dirs::usr::local 
    
    include shared file {
        "/usr/local/bin":
            ensure => directory,
            owner => "root",
            group => "$::shared::root_group",
            mode => 755;
    }
}

