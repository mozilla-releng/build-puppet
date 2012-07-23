class shared {
    # the appropriate /usr subdir for libraries; this is only useful
    # on linux platforms.
    $lib_arch_dir = $hardwaremodel ? {
        i686   => "lib",
        x86_64 => "lib64",
        default => "lib"
    }
}
