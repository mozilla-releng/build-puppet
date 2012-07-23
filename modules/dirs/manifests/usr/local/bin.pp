class dirs::usr::local::bin {
    include dirs::usr::local 
    include users::root
    
    include shared file {
        "/usr/local/bin":
            ensure => directory,
            owner => "root",
            group => "$users::root::group",
            mode => 755;
    }
}

