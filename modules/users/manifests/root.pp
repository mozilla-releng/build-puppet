# Set up the root user (or equvalent, e.g., Administrator on windows)

class users::root {
    include config

    ##
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

    ##
    # manage some configuration files

    python::user_pip_conf {
        $username:
            homedir => $home,
            group => $group,
            require => Class['users::root::account'];
    }

    # defer account creation to a subclass so we can require it
    class {
        'users::root::account':
            username => $username,
            group => $group,
            home => $home;
    }
}
