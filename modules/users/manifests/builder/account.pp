# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class users::builder::account($username, $group, $home) {
    include ::config

    ##
    # sanity checks

    if ($username == '') {
        fail('No builder username set')
    }

    ##
    # create the user

    case $::operatingsystem {
        CentOS, Ubuntu: {
            if ($config::secrets::builder_pw_hash == '') {
                fail('No builder password hash set')
            }

            user {
                $username:
                    password => $config::secrets::builder_pw_hash,
                    shell => "/bin/bash",
                    managehome => true,
                    comment => "Builder";
            }
        }
        Darwin: {
            if ($config::secrets::builder_pw_pbkdf2 == '' or $config::secrets::builder_pw_pbkdf2_salt == '') {
                fail('No builder password pbkdf2 set')
            }

            # use our custom type and provider, based on http://projects.puppetlabs.com/issues/12833
            # This should be replaced with 'user' once we are running a version of puppet containing the
            # relevant fixes.
            darwinuser {
                # NOTE: this user is *not* an Administrator.  All admin-level access is granted via sudoers.
                $username:
                    shell => "/bin/bash",
                    home => $home,
                    password => $::config::secrets::builder_pw_pbkdf2,
                    salt => $::config::secrets::builder_pw_pbkdf2_salt,
                    iterations => $::config::secrets::builder_pw_pbkdf2_iterations,
                    comment => "Builder";
            }
            file {
                $home:
                    ensure => directory,
                    owner => $username,
                    group => $group,
                    mode => 0755,
                    require => Darwinuser[$username];
            }
        }
    }
}
