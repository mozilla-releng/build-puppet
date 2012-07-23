class dirs::builds::hg-shared {
    include dirs::builds
    include users::builder

    file {
        "/builds/hg-shared":
            ensure => directory,
            owner => "$users::builder::username",
            group => "$users::builder::group",
            mode => 0755;
    }
}
