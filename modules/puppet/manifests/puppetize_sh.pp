class puppet::puppetize_sh {
    file {
        "/root/puppetize.sh":
            source => "puppet:///puppet/puppetize.sh",
            owner => root,
            group => root,
            mode => 0755;
    }
}
