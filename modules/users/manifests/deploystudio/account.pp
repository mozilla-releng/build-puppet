# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class users::deploystudio::account($username, $group, $grouplist, $home) {
    include ::config

    ##
    # sanity checks

    if ($username == '') {
        fail('No deploystudio username set')
    }

    ##
    # create the user

    case $::operatingsystem {
        Darwin: {
            # NOTE: this user is *not* an Administrator.  All admin-level access is granted via sudoers.
            case $::macosx_productversion_major {
                '10.6': {
                    if (secret("deploystudio_pw_paddedsha1") == '') {
                        fail('No deploystudio password paddedsha1 set')
                    }
                    user {
                        $username:
                            gid => $group,
                            shell => "/bin/bash",
                            home => $home,
                            password => secret("deploystudio_pw_paddedsha1"),
                            comment => "Deploystudio",
                            notify => Exec['kill-deploystudio-keychain'];
                    }
                    $user_req = User[$username]
                }
                '10.7': {
                    if (secret("deploystudio_pw_saltedsha512") == '') {
                        fail('No deploystudio password saltedsha512 set')
                    }
                    user {
                        $username:
                            gid => $group,
                            shell => "/bin/bash",
                            home => $home,
                            password => secret("deploystudio_pw_saltedsha512"),
                            comment => "Deploystudio",
                            notify => Exec['kill-deploystudio-keychain'];
                    }
                    $user_req = User[$username]
                }
                '10.8','10.9','10.10': {
                    if (secret("deploystudio_pw_pbkdf2") == '' or secret("deploystudio_pw_pbkdf2_salt") == '') {
                        fail('No deploystudio password pbkdf2 set')
                    }
                    user {
                        $username:
                            shell => "/bin/bash",
                            home => $home,
                            password => secret("deploystudio_pw_pbkdf2"),
                            salt => secret("deploystudio_pw_pbkdf2_salt"),
                            iterations => secret("deploystudio_pw_pbkdf2_iterations"),
                            comment => "Deploystudio",
                            notify => Exec['kill-deploystudio-keychain'];
                    }
                    $user_req = User[$username]
                }
                default: {
                    fail("No support for creating users on OS X $macosx_productversion_major")
                }
            }
            exec {
                # whenever the user password changes, we need to delete the keychain, otherwise
                # it will prompt on login
                'kill-deploystudio-keychain':
                    command => "/bin/rm -rf $home/Library/Keychains/login.keychain",
                    refreshonly => true;
            }
            file {
                $home:
                    ensure => directory,
                    owner => $username,
                    group => $group,
                    mode => 0755,
                    require => $user_req;
            }
        }
        default: {
            fail("Deploystudio is not supported on ${operationsystem}")
        }
    }
}
