class puppet::puppetize_sh {
    include users::root
    file {
        "${users::root::home}/puppetize.sh":
            source => "puppet:///modules/puppet/puppetize.sh",
            owner => root,
            group => $users::root::group,
            mode => 0755;
    }
}
