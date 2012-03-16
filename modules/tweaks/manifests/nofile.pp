class tweaks::nofile {
    # This class sets the file descriptor limit correctly,
    # which is needed to link b2g

    case $kernel {
        Linux: {
            file {
                # This should really be a template with the number of fds
                # that are desired
                "/etc/security/limits.d/90-nofile.conf":
                    owner => root,
                    group => root,
                    mode => 0644,
                    source => "puppet:///modules/tweaks/90-nofile.conf";
            }
        }
    }
}
