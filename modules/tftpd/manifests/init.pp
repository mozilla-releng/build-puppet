class tftpd {
    include packages::xinetd
    include packages::tftp-server

    case $operatingsystem {
        CentOS: {

            service {
                "xinetd":
                    require => Class["packages::xinetd"],
                    ensure  => running,
                    enable => true;
            }

            file {
                "/etc/xinetd.d/tftp":
                    ensure => file,
                    source => "puppet:///modules/tftpd/tftp",
                    notify => Service["xinetd"];
                "/var/lib/tftpboot":
                    ensure => directory;
                "/tftpboot":
                    ensure => link,
                    target => "/var/lib/tftpboot";
            }
        }
        default: {
            fail("Can't set up tftpd on this platform")
        }
    }
}
