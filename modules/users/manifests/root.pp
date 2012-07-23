# Set up the root user (or equvalent, e.g., Administrator on windows)

class users::root {
    include config

    # public variables used by other modules
    $username = 'root' # here for symmetry; no need to use this everywhere

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
                $username:
                    password => $config::secrets::root_pw_hash;
            }
        }
        Darwin: {
            notice('need to support setting the root password on OS X')
        }
    }

    python::user_pip_conf {
        $username:
            homedir => $home,
            group => $group;
    }
}
