class dirs::opt {
    file {
        "/opt":
            ensure => directory,
            mode => 755;
    }
}

