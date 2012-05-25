class puppet::atboot {
    include ::config
    include puppet::puppetize_sh

    $repo_servers = $::config::repo_servers
    $puppet_server = $::config::puppet_server
    notify {
        $repo_servers : ;
    }

    # signal puppetize.sh to reboot after this puppet run, if we're running
    # puppetize.sh (identified via the $puppetizing fact)
    if ($puppetizing) {
        file {
            "/REBOOT_AFTER_PUPPET":
                content => "please!";
        }
    }

    # install the list of puppetmaster mirrors
    file {
        "/etc/puppet/puppetmasters.txt":
            content => template("puppet/puppetmasters.txt.erb");
    }

    # create a service
    case $operatingsystem {
        CentOS: {
            file {
                "/etc/init.d/puppet":
                    mode => 0755,
                    owner => 'root',
                    group => 'root',
                    # puppet::install will overwrite this file, so make sure it gets
                    # installed first
                    require => Class['puppet::install'],
                    source => "puppet:///modules/puppet/puppet-centos-initd";
                "/etc/sysconfig/puppet":
                    content => template("puppet/sysconfig-puppet.erb");
            }

            service {
                "puppet":
                    require => [
                        File['/etc/init.d/puppet'],
                        File['/etc/sysconfig/puppet']
                    ],
                    # note we do not try to run the service (running)
                    enable => true;
            }
        }

        default: {
            fail("puppet::atboot support missing for $operatingsystem")
        }
    }
}

