# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class users::root::account($username, $group, $home) {
    include config

    ##
    # create the user

    case $::operatingsystem {
        CentOS, Ubuntu: {
            if (secret('root_pw_hash') == '') {
                fail('No root password hash set')
            }

            user {
                'root':
                    password => secret('root_pw_hash');
            }
        }
        Windows: {
            # Windows Puppet only verifies that root user is present and sets password
            user {
                'root':
                    ensure     => present,
                    forcelocal => true,
                    password   => secret('root_pw_cleartext');
            }
        }
        Darwin: {
            # use our custom type and provider, based on http://projects.puppetlabs.com/issues/12833
            case $::macosx_productversion_major {
                '10.7': {
                    if (secret('root_pw_saltedsha512') == '') {
                        fail('No root password saltedsha512 set')
                    }

                    darwinuser {
                        $username:
                            home     => $home,
                            password => secret('root_pw_saltedsha512');
                    }
                    $user_req = Darwinuser[$username]
                }
                '10.8': {
                    if (secret('root_pw_pbkdf2') == '' or secret('root_pw_pbkdf2_salt') == '') {
                        fail('No root password pbkdf2 set')
                    }

                    darwinuser {
                        $username:
                            home       => $home,
                            password   => secret('root_pw_pbkdf2'),
                            salt       => secret('root_pw_pbkdf2_salt'),
                            iterations => secret('root_pw_pbkdf2_iterations');
                    }
                    $user_req = Darwinuser[$username]
                }
                '10.9','10.10': {
                    if (secret('root_pw_pbkdf2') == '' or secret('root_pw_pbkdf2_salt') == '') {
                        fail('No root password pbkdf2 set')
                    }

                    user {
                        $username:
                            home       => $home,
                            password   => secret('root_pw_pbkdf2'),
                            salt       => secret('root_pw_pbkdf2_salt'),
                            iterations => secret('root_pw_pbkdf2_iterations');
                    }
                    $user_req = User[$username]
                }
                default: {
                    fail("No support for creating users on OS X ${::macosx_productversion_major}")
                }
            }
            file {
                # this should already exist, but this connects the user
                # creation with the automatic dependency on $home for files in
                # that directory
                $home:
                    ensure  => directory,
                    require => $user_req;
            }
        }
        default: {
            fail("cannot manage root account on ${::operatingsystem}")
        }
    }
}
