# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class puppet::atboot {
    include puppet
    include ::config
    include puppet::puppetize_sh
    include puppet::settings
    include packages::puppet
    include needs_reboot

    $puppet_server = $::puppet::settings::puppet_server
    $puppet_servers = $::puppet::settings::puppet_servers

    case ($::operatingsystem) {
        windows: {
            include dirs::etc
            $puppetmasters_txt = "${dirs::etc::dir}/puppetmasters.txt"
            # Temp work around on to DACLs being appended. 
            # REF: https://bugzilla.mozilla.org/show_bug.cgi?id=1170587 &  https://tickets.puppetlabs.com/browse/PUP-4802
            exec {
                'sec_descript_clear' :
                    command => 'C:\windows\system32\icacls.exe c:\etc\puppetmasters.txt /remove:g root',
                    require => File[$puppetmasters_txt],
            }
        }
        default: {
            $puppetmasters_txt = "${dirs::etc::dir}/puppet/puppetmasters.txt"
        }
    }

    # install the list of puppetmaster mirrors
    file {
        $puppetmasters_txt:
            content => template('puppet/puppetmasters.txt.erb');
    }

    # common (shell) source code for the startup scripts, used in templates
    $puppet_atboot_common = template('puppet/puppet-atboot-common.erb')

    # create a service
    case $::operatingsystem {
        CentOS: {
            # On CentOS, puppet runs from an initscript that blocks until the
            # puppet run is complete
            file {
                '/etc/init.d/puppet':
                    mode    => '0755',
                    owner   => 'root',
                    group   => 'root',
                    # packages::puppet will overwrite this file, so make sure it gets
                    # installed first
                    require => Class['packages::puppet'],
                    content => template('puppet/puppet-centos-initd.erb'),
                    # if we're editing init.d/puppet priority values
                    # on an existing machine
                    # then we need to explicitly force an update of the
                    # rc3.d symlink and we want to reboot because we've changed
                    # what we want to come after puppet in the boot order
                    notify  => [ Exec['initd-refresh'], Exec['reboot_semaphore'] ];
            }

            exec {
                'initd-refresh':
                    # resetpriorities tells chkconfig to update the
                    # symlinks in rcX.d with the values from the service's
                    # init.d script
                    command     => '/sbin/chkconfig puppet resetpriorities',
                    refreshonly => true;
            }

            service {
                'puppet':
                    require => File['/etc/init.d/puppet'],
                    # note we do not try to run the service (running)
                    enable  => true;
            }
        }
        Ubuntu: {
            # On Ubuntu, puppet runs by Upstart and on successful result
            # notifies dependent services
            file {
                '/etc/puppet/init':
                    mode    => '0755',
                    owner   => 'root',
                    group   => 'root',
                    content => template('puppet/puppet-ubuntu-initd.erb');
                '/etc/init/puppet.conf':
                    # this script special-cases the automatic start that the puppet
                    # package does, so it needs to be in place first
                    before => Class['packages::puppet'],
                    source => 'puppet:///modules/puppet/puppet.upstart.conf';
                '/etc/init.d/puppet':
                    ensure => link,
                    force  => true,
                    target => '/lib/init/upstart-job';
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
            include dirs::usr::local::bin
            file {
                '/Library/LaunchDaemons/com.mozilla.puppet.plist':
                    owner  => root,
                    group  => wheel,
                    mode   => '0644',
                    source => 'puppet:///modules/puppet/puppet-atboot.plist';
                '/usr/local/bin/run-puppet.sh':
                    owner   => root,
                    group   => wheel,
                    mode    => '0755',
                    content => template('puppet/puppet-darwin-run-puppet.sh.erb');
            }
        }
        Windows: {
            # On Windows, we use a runpuppet.rb script, run from a scheduled task.  It creates
            # a sempahore file when it's complete.
            include dirs::programdata::puppetagain
            $puppet_semaphore = 'C:\ProgramData\PuppetAgain\puppetcomplete.semaphore'
            file {
                'c:/programdata/puppetagain/runpuppet.rb':
                    content => template("${module_name}/puppet-atboot-runpuppet.rb.erb");
                'c:/programdata/puppetagain/runpuppet.xml':
                    content => template("${module_name}/puppet-atboot-runpuppet.xml.erb");
            }

            $schtasks = 'C:\Windows\system32\schtasks.exe'
            shared::execonce {
                'puppet-atboot-schtask':
                    command => "${schtasks} /Create /XML \"C:\\programdata\\puppetagain\\runpuppet.xml\" /tn RunPuppet",
                    require => File['c:/programdata/puppetagain/runpuppet.xml'];
            }
        }
        default: {
            fail("puppet::atboot support missing for ${::operatingsystem}")
        }
    }
}
