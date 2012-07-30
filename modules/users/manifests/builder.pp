# Set up the builder user - this is 'cltbld' on firefox systems, but flexible
# enough to be anything

class users::builder {
    include config

    ##
    # public variables used by other modules

    $username = $::config::builder_username

    #files are owned by staff group on macosx, rather than a group named after the user
    $group = $operatingsystem ? {
        Darwin => 'staff',
        default => $username
    }

    # calculate the proper homedir
    $home = $operatingsystem ? {
        Darwin => "/Users/$username",
        default => "/home/$username"
    }

    ##
    # Manage some configuration files

    file {
        "$home/.gitconfig":
            mode => 0644,
            owner => $username,
            group => $group,
            source => "puppet:///modules/users/gitconfig";
        "$home/.bashrc":
            mode => 0644,
            owner => $username,
            group => $group,
            content => template("${module_name}/builder-bashrc.erb");
        "$home/.hgrc":
            mode => 0644,
            owner => $username,
            group => $group,
            source => "puppet:///modules/users/hgrc";
        "$home/.vimrc":
            mode => 0644,
            owner => $username,
            group => $group,
            source => "puppet:///modules/users/vimrc";
        "$home/.screenrc":
            mode => 0644,
            owner => $username,
            group => $group,
            source => "puppet:///modules/users/screenrc";
    }

    ##
    # Tend to various things specific to the builder user
    
    case $operatingsystem {
        Darwin : {
            #Probably too late at this point, but lets get rid of them for the next reboot
            tidy {
                "$home/Library/Saved\ Application\ State/*.savedState":
            }
        }
    }

    python::user_pip_conf {
        $username:
            homedir => $home,
            group => $group;
    }

    class {
        'ssh::setup':
            home => $home,
            owner => $username,
            group => $group;
        'ssh::common_known_hosts':
            home => $home,
            owner => $username,
            group => $group;
    }

    ##
    # defer account creation to a subclass so we can require it

    class {
        'users::builder::account':
            username => $username,
            group => $group,
            home => $home;
    }
}

