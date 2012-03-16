class dirs::builds {
    file {
        "/builds/":
            ensure => directory,
            mode => 0755;
    }
}
