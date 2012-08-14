class ssh::settings {
    # config files' paths are different per platform
    case $operatingsystem {
        CentOS: {
            $ssh_config = "/etc/ssh/ssh_config"
            $sshd_config = "/etc/ssh/sshd_config"
        }
        Darwin: {
            $ssh_config = "/etc/ssh_config"
            $sshd_config = "/etc/sshd_config"
        }
        default: {
            fail("Don't know how to configure SSH on this platform")
        }
    }
}
