# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class users::root::autologin {
    include users::root

    case $::operatingsystem {
        Darwin: {
            file {
                # this file contains a lightly obscured copy of the password
                '/etc/kcpassword':
                    content   => base64decode(secret('root_pw_kcpassword_base64')),
                    owner     => root,
                    group     => wheel,
                    mode      => '0600',
                    show_diff => false;
            }
            osxutils::defaults {
                'autoLoginUser':
                    domain => '/Library/Preferences/com.apple.loginwindow',
                    key    => 'autoLoginUser',
                    value  => $::users::root::username;
            }
        }
        Ubuntu: {
            # Managed by xvfb/Xsession
        }
        default: {
            fail("Don't know how to set up autologin on ${::operatingsystem}")
        }
    }

    ##
    # disable account-specific services

    class {
        'disableservices::user':
            username => $users::root::username,
            group    => $users::root::group,
            home     => $users::root::home;
    }
}
