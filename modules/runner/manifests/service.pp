# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Make sure runner runs at boot
class runner::service {
    include runner::settings
    case $::operatingsystem {
        'CentOS': {
            file {
                '/etc/init.d/runner':
                    content => template('runner/runner.initd.erb'),
                    mode    => '0755',
                    notify  => Exec['initd-r-refresh'];
            }
            exec {
                'initd-r-refresh':
                    # resetpriorities tells chkconfig to update the
                    # symlinks in rcX.d with the values from the service's
                    # init.d script
                    command     => '/sbin/chkconfig runner resetpriorities',
                    refreshonly => true;
            }
            service {
                'runner':
                    require   => [
                        Python::Virtualenv[$runner::settings::root],
                    ],
                    hasstatus => false,
                    enable    => true;
            }
        }
        'Ubuntu': {
            case $::operatingsystemrelease {
                12.04,14.04: {
                    file {
                        '/etc/init/runner.conf':
                            content => template('runner/runner.upstart.conf.erb');
                    }
                    service {
                        'runner':
                            require   => [
                                Python::Virtualenv[$runner::settings::root],
                                File['/etc/init/runner.conf'],
                            ],
                            hasstatus => false,
                            enable    => true;
                    }
                }
                16.04: {
                    file {
                        '/lib/systemd/system/runner.service':
                            content => template('runner/runner.service.erb');
                    }
                    service {
                        'runner':
                            provider  => 'systemd',
                            require   => [
                                Python::Virtualenv[$runner::settings::root],
                                File['/lib/systemd/system/runner.service'],
                            ],
                            hasstatus => false,
                            enable    => true;
                    }
                }
                default: {
                    fail("Ubuntu ${::operatingsystemrelease} is not supported")
                }
            }
        }
        'Darwin': {
            file {
                '/Library/LaunchAgents/com.mozilla.runner.plist':
                    owner   => root,
                    group   => wheel,
                    mode    => '0644',
                    content => template('runner/runner.plist.erb');
            }
            service {
                'runner':
                    require   => [
                        Python::Virtualenv[$runner::settings::root],
                        File['/Library/LaunchAgents/com.mozilla.runner.plist'],
                    ],
                    hasstatus => false,
                    enable    => true;
            }
        }
        'Windows': {
        # On Windows Runner is luanched on each log in of cltbld and is not running as a service
            include users::builder
            include dirs::programdata::puppetagain

            $builder_username = $users::builder::username
            $puppet_semaphore = 'C:\ProgramData\PuppetAgain\puppetcomplete.semaphore'
            # Batch file to start buildbot
            file {
                'c:/programdata/puppetagain/start-runner.bat':
                    content  => template('runner/start-runner.bat.erb');
            }
            # XML file to set up a schedule task to launch runner on builder log in.
            # XML file needs to exported from the task scheduler gui. Also note when
            # using the XML import be aware of machine specific values such as name will
            # need to be replaced with a variable. Hence the need for the template.
            file {
                'c:/programdata/puppetagain/start-runner.xml':
                    content => template('runner/start-runner.xml.erb');
            }
            # Importing the XML file using schtasks
            # Refrence http://technet.microsoft.com/en-us/library/cc725744.aspx and http://technet.microsoft.com/en-us/library/cc722156.aspx
            $schtasks         = 'C:\Windows\system32\schtasks.exe'
            exec { 'startrunner':
                command     => "${schtasks} /Create /XML c:\\programdata\\puppetagain\\start-runner.xml /tn StartRunner",
                require     => File['c:/programdata/puppetagain/start-runner.xml'],
                refreshonly => true,
                subscribe   => File['c:/programdata/puppetagain/start-runner.bat'],
            }
        }
        default: {
            fail("Unsupported OS ${::operatingsystem}")
        }
    }
}
