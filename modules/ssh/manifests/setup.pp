class ssh::setup($home, $owner, $group) {

    file {
        "$home/.ssh":
            ensure => directory,
            mode => 0755,
            owner => $owner,
            group => $group;
        "$home/.ssh/config":
            mode => 0644,
            owner => $owner,
            group => $group,
            source => "puppet:///modules/ssh/ssh_config";
        # XXX Authorized keys should be generated from LDAP not a static file
        "$home/.ssh/authorized_keys":
            mode => 0644,
            owner => $owner,
            group => $group,
            content => template("ssh/ssh_authorized_keys.erb");
    }
}
