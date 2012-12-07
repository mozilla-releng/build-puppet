class dirs::builds::git-shared {
    include dirs::builds
    include users::builder

    file {
        "/builds/git-shared":
            ensure => directory,
            owner => "$users::builder::username",
            group => "$users::builder::group",
            mode => 0755;
    }
}
