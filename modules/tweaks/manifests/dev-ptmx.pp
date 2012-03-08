class tweaks::dev-ptmx {
    # See https://bugzilla.mozilla.org/show_bug.cgi?id=568035
    # It's not clear how this file's permission might get changed, but this
    # will ensure it's correct.  This seems applicable for all Linux versions,
    # although it has not been tested on Ubuntu.

    case $kernel {
        Linux: {
            file {
                "/dev/ptmx":
                    mode => 666,
                    owner => "root",
                    group => "tty";
            }
        }
    }
}
