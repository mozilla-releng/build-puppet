# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class users::builder::autologin {
    include users::builder

    case $::operatingsystem {
        Darwin: {
            file {
                #this file contains a lightly obscured copy of the password
                "/etc/kcpassword":
                    content => base64decode(secret("builder_pw_kcpassword_base64")),
                    owner => root,
                    group => wheel,
                    mode => 600,
                    show_diff => false;
            }
            osxutils::defaults {
                autoLoginUser:
                    domain => "/Library/Preferences/com.apple.loginwindow",
                    key => 'autoLoginUser',
                    value => $::users::builder::username;
            }
        }
        Ubuntu: {
            #Managed by xvfb/Xsession
        }
        Windows: {
            #In Windows autologin is setup through registry settings
            registry::value { 'AutoAdminLogon':
                key    => "HKLM\\SOFTWARE\\Microsoft",
                data   => '1',
            }
            registry::value { 'DefaultDomainName':
                key    => "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\WinLogon",
                data   => '.',
            }
            registry::value { 'DefaultPassword':
                key    => "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\WinLogon",
                data   => secret("builder_pw_cleartext"),
            }
            registry::value { 'DefaultUserName':
                key    => "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\WinLogon",
                data   => 'cltbld',
            }
            registry::value { 'AutoLogonCount':
                key    => "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\WinLogon",
                type   => dword,
                data   => '100000',
            }
            #Enables Clean Desktop Exp. managaer. See  http://technet.microsoft.com/en-us/library/ee344834.aspx for refrence.
            exec { "cleanmgr":
                creates => 'C:\programdata\PuppetLabs\puppet\var\lib\cleandesktopresults.xml',
                command => 'C:\Windows\System32\servermanagercmd.exe -install Desktop-Experience -resultPath C:\programdata\PuppetLabs\puppet\var\lib\cleandesktopresults',
            }
        }
        default: {
            fail("Don't know how to set up autologin on $::operatingsystem")
        }
    }
}
