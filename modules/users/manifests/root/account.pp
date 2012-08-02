class users::root::account($username, $group, $home) {
    include config

    ##
    # create the user

    case $::operatingsystem {
        CentOS: {
            if ($config::secrets::root_pw_hash == '') {
                fail('No root password hash set')
            }

            user {
                "root":
                    password => $config::secrets::root_pw_hash;
            }
        }
        Darwin: {
            if ($::config::secrets::root_pw_pbkdf2 == ''
                    or $::config::secrets::root_pw_pbkdf2_salt == '') {
                fail('No root password pbkdf2 set')
            }

            # use our custom type and provider, based on http://projects.puppetlabs.com/issues/12833
            darwinuser {
                $username:
                    home => $home,
                    password => $::config::secrets::root_pw_pbkdf2,
                    salt => $::config::secrets::root_pw_pbkdf2_salt,
                    iterations => $::config::secrets::root_pw_pbkdf2_iterations;
            }
            file {
                # this should already exist, but this connects the user
                # creation with the automatic dependency on $home for files in
                # that directory
                $home:
                    ensure => directory,
                    require => Darwinuser[$username];
            }
        }
    }
}
