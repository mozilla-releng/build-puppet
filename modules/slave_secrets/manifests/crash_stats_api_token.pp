# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla..org/MPL/2.0/.

class slave_secrets::crash_stats_api_token($ensure=present) {
    include config
    include users::builder
    include dirs::builds

    $crash_stats_api_token = $::operatingsystem ? {
        windows => 'C:/builds/crash-stats-api.token',
        default => '/builds/crash-stats-api.token'
    }

    if ($ensure == 'present' and $config::install_crash_stats_api_token) {
        case $::operatingsystem {
            Windows: {
                file {
                    $crash_stats_api_token:
                        content   => secret('crash_stats_api_token'),
                        show_diff => false;
                }
                acl {
                    $crash_stats_api_token:
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
                    $crash_stats_api_token:
                        content   => secret('crash_stats_api_token'),
                        owner     => $::users::builder::username,
                        group     => $::users::builder::group,
                        mode      => '0600',
                        show_diff => false;
                }
            }
        }
    } else {
        file {
            $crash_stats_api_token:
                ensure => absent;
        }
    }
}
