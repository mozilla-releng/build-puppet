# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class users::roller::account($username, $group, $grouplist, $home) {
    include ::config
    include needs_reboot

    ##
    # sanity checks

    if ($username == '') {
        fail('No roller username set')
    }

    ##
    # create the user

    case $::operatingsystem {
        Darwin: {
            # use our custom type and provider, based on http://projects.puppetlabs.com/issues/12833
            # This should be replaced with 'user' once we are running a version of puppet containing the
            # relevant fixes.
            # NOTE: this user is *not* an Administrator.  All admin-level access is granted via sudoers.
            case $::macosx_productversion_major {
                '10.10': {
                    if (secret('roller_pw_pbkdf2') == '' or secret('roller_pw_pbkdf2_salt') == '') {
                        fail('No roller password pbkdf2 set')
                    }
                    user {
                        $username:
                            shell      => '/bin/bash',
                            home       => $home,
                            password   => secret('roller_pw_pbkdf2'),
                            salt       => secret('roller_pw_pbkdf2_salt'),
                            iterations => secret('roller_pw_pbkdf2_iterations'),
                            comment    => 'roller',
                            groups     => $grouplist,
                            notify     => Exec['kill-roller-keychain','reboot_semaphore'];
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
                'kill-roller-keychain':
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
        default: {
            fail("roller account is not set up for ${::operatingsystem} reboots")
        }
    }
}
