# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class users::signer::account($username, $group, $grouplist, $home) {
    include ::config

    ##
    # sanity checks

    if ($username == '') {
        fail('No signer username set')
    }

    ##
    # create the user

    case $::operatingsystem {
        CentOS, Ubuntu: {
            if (secret('signer_pw_hash') == '') {
                fail('No signer password hash set')
            }

            user {
                $username:
                    password   => secret('signer_pw_hash'),
                    shell      => '/bin/bash',
                    managehome => true,
                    groups     => $grouplist,
                    comment    => 'Signer';
            }
        }
        Darwin: {
            # use our custom type and provider, based on http://projects.puppetlabs.com/issues/12833
            # This should be replaced with 'user' once we are running a version of puppet containing the
            # relevant fixes.
            # NOTE: this user is *not* an Administrator.  All admin-level access is granted via sudoers.
            case $::macosx_productversion_major {
                '10.9','10.10': {
                    if (secret('signer_pw_pbkdf2') == '' or secret('signer_pw_pbkdf2_salt') == '') {
                        fail('No signer password pbkdf2 set')
                    }
                    user {
                        $username:
                            shell      => '/bin/bash',
                            home       => $home,
                            password   => secret('signer_pw_pbkdf2'),
                            salt       => secret('signer_pw_pbkdf2_salt'),
                            iterations => secret('signer_pw_pbkdf2_iterations'),
                            comment    => 'Builder',
                            notify     => Exec['kill-signer-keychain'];
                    }
                    $user_req = User[$username]
                }
                default: {
                    fail("No support for creating users on OS X ${::macosx_productversion_major}")
                }
            }
            exec {
                # whenever the user password changes, we need to delete the keychain, otherwise
                # it will prompt on login
                'kill-signer-keychain':
                    command     => "/bin/rm -rf ${home}/Library/Keychains/login.keychain",
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
