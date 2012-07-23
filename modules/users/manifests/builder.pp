# Set up the builder user - this is 'cltbld' on firefox systems, but flexible
# enough to be anything

class users::builder {
    include config
    include users::settings
    include shared::builder
    
    if ($config::secrets::builder_pw_hash == '') {
        fail('No builder password hash set')
    }

    if ($config::builder_username == '') {
        fail('No builder username set')
    }

    # calculate the proper homedir
    $home_dir = $users::settings::home_dir
    $group = $shared::builder::group
    case $operatingsystem {
        CentOS : {
            user {
                "$config::builder_username" :
                    password => $config::secrets::builder_pw_hash,
                    shell => "/bin/bash",
                   comment => "Builder" ;
            }
       }
       Darwin : {
        #build user is temporarily created by base image until "user" on 10.8 is fixed in puppet
       }
   }
  
    # Manage some configuration files
          # Manage some configuration files
    file {
        "$home_dir/.ssh":
            ensure => directory,
            mode => 0755,
            owner => "$config::builder_username",
            group =>"$group";
        "$home_dir/.ssh/config":
            mode => 0644,
            owner => "$config::builder_username",
            group => "$group",
            source => "puppet:///modules/users/ssh_config";
        # XXX Authorized keys should be generated from LDAP not a static file
        "$home_dir/.ssh/authorized_keys":
            mode => 0644,
            owner => "$config::builder_username",
            group => "$group",
            content => template("users/ssh_authorized_keys.erb");
        "$home_dir/.ssh/known_hosts":
            mode => 0644,
            owner => "$config::builder_username",
            group => "$group",
            source => "puppet:///modules/users/ssh_known_hosts";
        "$home_dir/.gitconfig":
            mode => 0644,
            owner => "$config::builder_username",
            group => "$group",
            source => "puppet:///modules/users/gitconfig";
        "$home_dir/.bashrc":
            mode => 0644,
            owner => "$config::builder_username",
            group => "$group",
            content => template("${module_name}/builder-bashrc.erb");
        "$home_dir/.hgrc":
            mode => 0644,
            owner => "$config::builder_username",
            group => "$group",
            source => "puppet:///modules/users/hgrc";
        "$home_dir/.vimrc":
            mode => 0644,
            owner => "$config::builder_username",
            group => "$group",
            source => "puppet:///modules/users/vimrc";
        "$home_dir/.screenrc":
            mode => 0644,
            owner => "$config::builder_username",
            group => "$group",
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
        "$config::builder_username": ;
    }
}

