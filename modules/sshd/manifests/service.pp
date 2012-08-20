class sshd::service {
    case $operatingsystem {
        CentOS : {
            # running by default
        }
        Darwin : {
            exec {
                # Using -w will enable the service for future boots, this
                # command does tick the box for remote-login in the Sharing
                # prefpane (survives reboot)
                "turn-on-ssh" :
                    command =>
                    "/bin/launchctl load -w /System/Library/LaunchDaemons/ssh.plist",
                    unless =>
                    "/usr/sbin/netstat -na | /usr/bin/grep -q 'tcp4.*\*.22.*LISTEN'";
            }

            # Delete the com.apple.access_ssh group.  If present, this group limits
            # SSH logins to those in the group, but without it, any user can log in.
            group {
                'com.apple.access_ssh':
                    ensure => absent;
            }
        }
    }
}
