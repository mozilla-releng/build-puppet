# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class users::root::account($username, $group, $home) {
    include config

    ##
    # create the user

    case $::operatingsystem {
        CentOS: {
            if ($config::secrets::root_pw_hash == '') {
                fail('No root password hash set')
            }

            user {
                "root":
                    password => $config::secrets::root_pw_hash;
            }
        }
        Darwin: {
            if ($::config::secrets::root_pw_pbkdf2 == ''
                    or $::config::secrets::root_pw_pbkdf2_salt == '') {
                fail('No root password pbkdf2 set')
            }

            # use our custom type and provider, based on http://projects.puppetlabs.com/issues/12833
            case $::macosx_productversion_major {
                '10.7': {
                    darwinuser {
                        $username:
                            home => $home,
                            password => $::config::secrets::root_pw_saltedsha512;
                    }
                }
                '10.8': {
                    darwinuser {
                        $username:
                            home => $home,
                            password => $::config::secrets::root_pw_pbkdf2,
                            salt => $::config::secrets::root_pw_pbkdf2_salt,
                            iterations => $::config::secrets::root_pw_pbkdf2_iterations;
                    }
                }
            }
            file {
                # this should already exist, but this connects the user
                # creation with the automatic dependency on $home for files in
                # that directory
                $home:
                    ensure => directory,
                    require => Darwinuser[$username];
            }
        }
    }
}
