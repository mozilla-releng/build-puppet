class dirs::opt::bmm {
    include dirs::opt
    file {
        "/opt/bmm":
            ensure => directory,
            mode => 0755;
    }
}

