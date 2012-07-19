class dirs::builds::logs {
    include dirs::builds
    include shared

    file {
            "/builds/logs" :
            ensure => directory,
            owner => "root",
            group => "$::shared::root_group",
            mode => 0755;
    }
}