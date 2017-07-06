# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla..org/MPL/2.0/.

class slave_secrets::google_oauth_api_key($ensure=present) {
    include config
    include users::builder
    include dirs::builds

    $google_oauth_api_key = $::operatingsystem ? {
        windows => 'C:/builds/google-oauth-api.key',
        default => '/builds/google-oauth-api.key'
    }

    if ($ensure == 'present' and $config::install_google_oauth_api_key) {
        case $::operatingsystem {
            Windows: {
                file {
                    'C:/builds/google-oauth-api.key':
                        content   => secret('google_oauth_api_key'),
                        show_diff => false;
                }
                acl {
                    'C:/builds/google-oauth-api.key':
                        purge                      => true,
                        inherit_parent_permissions => false,
                        # indentation of => is not properly aligned in hash within array: The solution was provided on comment 2
                        # https://github.com/rodjek/puppet-lint/issues/333
                        permissions                => [
                            {
                              identity => 'root',
                              rights   => ['full'] },
                            {
                              identity => 'SYSTEM',
                              rights   => ['full'] },
                            {
                              identity => 'cltbld',
                              rights   => ['full'] },
                        ];
                }
            }
            default: {
                file {
                    $google_oauth_api_key:
                        content   => secret('google_oauth_api_key'),
                        owner     => $::users::builder::username,
                        group     => $::users::builder::group,
                        mode      => '0600',
                        show_diff => false;
                }
            }
        }
    } else {
        file {
            $google_oauth_api_key:
                ensure => absent;
        }
    }
}
