class dirs::builds::hg-shared {
    include dirs::builds

    file {
        "/builds/hg-shared":
            ensure => directory,
            owner => "$config::builder_username",
            group => "$config::builder_username",
            mode => 0755;
    }
}
