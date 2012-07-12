# These are machines that connect to our mobile testers and act as build slaves
# However these do not reboot frequently, and typically handle multiple
# buildbot instances at once.

class toplevel::server::foopy inherits toplevel::server {
    include ::foopy
}

