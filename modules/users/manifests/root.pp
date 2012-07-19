# Set up the root user (or equvalent, e.g., Administrator on windows)

class users::root {
    include config

    # public variables used by other modules
    $group = $::operatingsystem ? {
        Darwin => wheel,
        default => root
    }

    $home = $operatingsystem ? {
        Darwin => '/var/root',
        default => '/root'
    }

    if ($config::secrets::root_pw_hash == '') {
        fail('No root password hash set')
    }
    
    case $::operatingsystem {
        CentOS: {
            user {
                "root":
                    password => $config::secrets::root_pw_hash;
            }
        }
        Darwin: {
            notice('need to support setting the root password on OS X')
        }
    }

    python::user_pip_conf {
        "root":
            homedir => $home,
            group => $group;
    }
}
