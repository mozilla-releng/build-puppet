# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class puppet::atboot {
    include puppet
    include ::config
    include puppet::puppetize_sh
    include puppet::settings
    include packages::puppet
    include dirs::usr::local::bin

    $puppet_server = $::puppet::settings::puppet_server
    $puppet_servers = $::puppet::settings::puppet_servers

    # signal puppetize.sh to reboot after this puppet run, if we're running
    # puppetize.sh (identified via the $puppetizing fact)
    if ($puppetizing) {
        file {
            "/REBOOT_AFTER_PUPPET":
                content => "please!";
        }
    }

    # and allow other systems to request a reboot as well (e.g., for installing
    # kernel drivers)

    exec {
        # ask the puppet startup script to reboot
        "reboot-after-puppet":
            command => "/usr/bin/touch /REBOOT_AFTER_PUPPET",
            refreshonly => true;
    }

    # install the list of puppetmaster mirrors
    file {
        "/etc/puppet/puppetmasters.txt":
            content => template("puppet/puppetmasters.txt.erb");
    }

    # common source code for the startup scripts, used in templates
    $puppet_atboot_common = template("puppet/puppet-atboot-common.erb")

    # create a service
    case $::operatingsystem {
        CentOS: {
            # On CentOS, puppet runs from an initscript that blocks until the
            # puppet run is complete
            file {
                "/etc/init.d/puppet":
                    mode => 0755,
                    owner => 'root',
                    group => 'root',
                    # packages::puppet will overwrite this file, so make sure it gets
                    # installed first
                    require => Class['packages::puppet'],
                    content => template("puppet/puppet-centos-initd.erb");
            }

            service {
                "puppet":
                    require => File['/etc/init.d/puppet'],
                    # note we do not try to run the service (running)
                    enable => true;
            }
        }
        Ubuntu: {
            # On Ubuntu, puppet runs by Upstart and on successful result
            # notifies dependent services
            file {
                "/etc/puppet/init":
                    mode => 0755,
                    owner => 'root',
                    group => 'root',
                    content => template("puppet/puppet-ubuntu-initd.erb");
                "/etc/init/puppet.conf":
                    source => "puppet:///modules/puppet/puppet.upstart.conf";
                "/etc/init.d/puppet":
                    ensure => link,
                    force  => true,
                    target => "/lib/init/upstart-job";
            }
        }

        Darwin: {
            # On Darwin, puppet runs as a system-level launch daemon.  This
            # runs run-puppet.sh, which is similar to the CentOS initscript.
            # However, launchd provides no way to block system startup, so
            # other launchd daemons are started while puppet is running, and
            # the autologin takes place.  The script touches a semaphore file
            # when puppet has run to completion, and this signals the user-level
            # launchd to start the buildslave daemon.  Got that?
            file {
                "/Library/LaunchDaemons/com.mozilla.puppet.plist":
                    owner => root,
                    group => wheel,
                    mode => 0644,
                    source => "puppet:///modules/puppet/puppet-atboot.plist";
                "/usr/local/bin/run-puppet.sh":
                    owner => root,
                    group => wheel,
                    mode => 0755,
                    content => template("puppet/puppet-darwin-run-puppet.sh.erb");
            }
        }
        default: {
            fail("puppet::atboot support missing for $::operatingsystem")
        }
    }
}
