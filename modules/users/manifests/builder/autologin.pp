class users::builder::autologin {
    include config::secrets
    include users::builder

    case $::operatingsystem {
        Darwin: {
            file {
                # this file contains a lightly obscured copy of the password
                "/etc/kcpassword":
                    content => base64decode($::config::secrets::builder_pw_kcpassword_base64),
                    owner => root,
                    group => wheel,
                    mode => 600;
            }
            osxutils::defaults {
                autoLoginUser:
                    domain => "/Library/Preferences/com.apple.loginwindow",
                    key => 'autoLoginUser',
                    value => $::users::builder::username;
            }
        }
        default: {
            fail("Don't know how to set up autologin on $::operatingsystem")
        }
    }
}
