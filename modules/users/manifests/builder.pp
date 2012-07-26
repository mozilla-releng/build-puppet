# Set up the builder user - this is 'cltbld' on firefox systems, but flexible
# enough to be anything

class users::builder {
    include config

    # public variables used by other modules
    $username = $::config::builder_username

    #files are owned by staff group on macosx, rather than a group named after the user
    $group = $operatingsystem ? {
        Darwin => 'staff',
        default => $username
    }

    # specifying the uid is temporary util usr is fixed on 10.8 in puppet   
    # (http://projects.puppetlabs.com/issues/12833)
    $uid = $operatingsystem ? {
        Darwin => 501,
        default => 500
    }

    # calculate the proper homedir
    $home = $operatingsystem ? {
        Darwin => "/Users/$username",
        default => "/home/$username"
    }

    # sanity checks

    if ($config::secrets::builder_pw_hash == '') {
        fail('No builder password hash set')
    }

    if ($username == '') {
        fail('No builder username set')
    }

    case $::operatingsystem {
        CentOS: {
            user {
                $username:
                    password => $config::secrets::builder_pw_hash,
                    shell => "/bin/bash",
                    managehome => true,
                    comment => "Builder";
            }
        }
        Darwin: {
            # TODO, pending http://projects.puppetlabs.com/issues/12833
        }
    }

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
    
    case $operatingsystem {
        Darwin : {
            include packages::mozilla::screenresolution 
            exec {
            # we are still deploying the launchagent for when the machine is loaned to
            # devs.  If you change the resolution here, please change it in
            # "${platform_fileroot}/Library/LaunchAgents/screenresolution.plist"
            # as well
                "verify-resolution" :
                    command =>
                    "/usr/local/bin/screenresolution set 1280x1024x32",
                    unless =>
                    "/usr/local/bin/screenresolution get 2>&1 | /usr/bin/grep 'Display 0: 1280x1024x32'",
                    require => Class["packages::mozilla::screenresolution"]
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
}

