# Set up the root user (or equvalent, e.g., Administrator on windows)

class users::root {
    include config

    if ($config::secrets::root_pw_hash == '') {
        fail('No root password hash set')
    }
    
    user {
        "root":
            password => $config::secrets::root_pw_hash;
    }

    $home = $operatingsystem ? {
        Darwin => '/var/root',
        default => '/root'
    }

    python::user_pip_conf {
        "root":
            homedir => $home;
    }
}
