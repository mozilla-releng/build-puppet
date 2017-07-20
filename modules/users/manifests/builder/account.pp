# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class users::builder::account($username, $group, $grouplist, $home) {
    include ::config
    include needs_reboot

    ##
    # sanity checks

    if ($username == '') {
        fail('No builder username set')
    }

    ##
    # create the user

    case $::operatingsystem {
        CentOS, Ubuntu: {
            if (secret('builder_pw_hash') == '') {
                fail('No builder password hash set')
            }

            user {
                $username:
                    password   => secret('builder_pw_hash'),
                    shell      => '/bin/bash',
                    managehome => true,
                    groups     => $grouplist,
                    comment    => 'Builder';
            }
        }
        Windows: {
            user {
                $username:
                    password   => secret('builder_pw_cleartext'),
                    groups     => ['Administrators','Remote Desktop Users'],
                    managehome => true,
                    comment    => 'Builder';
            }
        }
        Darwin: {
            # use our custom type and provider, based on http://projects.puppetlabs.com/issues/12833
            # This should be replaced with 'user' once we are running a version of puppet containing the
            # relevant fixes.
            # NOTE: this user is *not* an Administrator.  All admin-level access is granted via sudoers.
            case $::macosx_productversion_major {
                '10.7': {
                    if (secret('builder_pw_saltedsha512') == '') {
                        fail('No builder password saltedsha512 set')
                    }
                    darwinuser {
                        $username:
                            gid      => $group,
                            shell    => '/bin/bash',
                            home     => $home,
                            password => secret('builder_pw_saltedsha512'),
                            comment  => 'Builder',
                            notify   => Exec['kill-builder-keychain'];
                    }
                    $user_req = Darwinuser[$username]
                }
                '10.8': {
                    if (secret('builder_pw_pbkdf2') == '' or secret('builder_pw_pbkdf2_salt') == '') {
                        fail('No builder password pbkdf2 set')
                    }
                    darwinuser {
                        $username:
                            shell      => '/bin/bash',
                            home       => $home,
                            password   => secret('builder_pw_pbkdf2'),
                            salt       => secret('builder_pw_pbkdf2_salt'),
                            iterations => secret('builder_pw_pbkdf2_iterations'),
                            comment    => 'Builder',
                            notify     => Exec['kill-builder-keychain'];
                    }
                    $user_req = Darwinuser[$username]
                }
                '10.9','10.10': {
                    if (secret('builder_pw_pbkdf2') == '' or secret('builder_pw_pbkdf2_salt') == '') {
                        fail('No builder password pbkdf2 set')
                    }
                    user {
                        $username:
                            shell      => '/bin/bash',
                            home       => $home,
                            password   => secret('builder_pw_pbkdf2'),
                            salt       => secret('builder_pw_pbkdf2_salt'),
                            iterations => secret('builder_pw_pbkdf2_iterations'),
                            comment    => 'Builder',
                            groups     => $grouplist,
                            notify     => Exec['kill-builder-keychain','reboot_semaphore'];
                    }
                    $user_req = User[$username]
                }
                default: {
                    fail("Cannot create user on OS X ${::macosx_productversion_major}")
                }
            }
            exec {
                # whenever the user password changes, we need to delete the keychain, otherwise
                # it will prompt on login
                'kill-builder-keychain':
                    command     => "/bin/rm -rf ${home}/Library/Keychains/login.keychain",
                    notify      => Exec['reboot_semaphore'],
                    refreshonly => true;
            }
            file {
                $home:
                    ensure  => directory,
                    owner   => $username,
                    group   => $group,
                    mode    => '0755',
                    require => $user_req;
            }
        }
    }
}
