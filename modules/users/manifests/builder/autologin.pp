# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class users::builder::autologin {
    include users::builder

    case $::operatingsystem {
        Darwin: {
            file {
                # this file contains a lightly obscured copy of the password
                '/etc/kcpassword':
                    content   => base64decode(secret('builder_pw_kcpassword_base64')),
                    owner     => root,
                    group     => wheel,
                    mode      => '0600',
                    show_diff => false;
            }
            osxutils::defaults {
                'autoLoginUser':
                    domain => '/Library/Preferences/com.apple.loginwindow',
                    key    => 'autoLoginUser',
                    value  => $::users::builder::username;
            }
        }
        Ubuntu: {
            # Managed by xvfb/Xsession
        }
        Windows: {
            include tweaks::pwrshell_options
            include dirs::etc

            $builder_username = $config::builder_username

            # In Windows autologin is setup through registry settings
            registry::value { 'AutoAdminLogon':
                key  => 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon',
                data => '1',
            }
            registry::value { 'DefaultDomainName':
                key  => 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon',
                data => '.',
            }
            registry::value { 'DefaultPassword':
                key  => 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon',
                data => secret('builder_pw_cleartext'),
            }
            registry::value { 'DefaultUserName':
                key  => 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon',
                data => $config::builder_username,
            }
            registry::value { 'AutoLogonCount':
                key  => 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon',
                type => dword,
                data => '100000',
            }
            # Enables Clean Desktop Exp. feature. See http://technet.microsoft.com/en-us/library/jj205467.aspx.
            case $::env_os_version {
                2008: {
                    shared::execonce { 'desktop_exp':
                        command  => 'Import-Module Servermanager; Add-WindowsFeature Desktop-Experience ',
                        provider => powershell,
                    }
                }
                default: {
                    # Only needed for Windows Server OSes
                }
            }
            # In the scenario where there is no live management the logon count could possible become 0
            # The following resets the count on login of the build user 
            #
            # XML file to set up a schedule task to reset logon value.
            # XML file needs to exported from the task scheduler gui. Also note when using the XML import be aware of machine specific values such as name will need to be replaced with a variable.
            # Hence the need for the template.
            file {'C:/programdata/puppetagain/Update_Logon_Count.xml':
                content => template('users/Update_Logon_Count.xml.erb'),
            }
            # Importing the XML file using schtasks
            # Refrence http://technet.microsoft.com/en-us/library/cc725744.aspx and http://technet.microsoft.com/en-us/library/cc722156.aspx
            shared::execonce { 'Update_Logon_Count':
                command => '"C:\Windows\system32\schtasks.exe" /Create  /XML "C:/programdata/puppetagain/Update_Logon_Count.xml" /tn Update_Logon_Count.xml',
                require => File['C:/programdata/puppetagain/Update_Logon_Count.xml'];
            }
        }
        default: {
            fail("Don't know how to set up autologin on ${::operatingsystem}")
        }
    }

    ##
    # disable account-specific services

    class {
        'disableservices::user':
            username => $users::builder::username,
            group    => $users::builder::group,
            home     => $users::builder::home;
    }
}
