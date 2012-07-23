class dirs::builds::logs {
    include dirs::builds
    include users::root
    include shared

    file {
            "/builds/logs" :
            ensure => directory,
            owner => "root",
            group => "$users::root::group",
            mode => 0755;
    }
}
