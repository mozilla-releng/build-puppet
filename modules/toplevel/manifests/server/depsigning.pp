# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class toplevel::server::depsigning inherits toplevel::server {
    include config
    include ::security

    $signing_server_username     = secret('signing_server_username')
    $signing_server_dep_password = secret('signing_server_dep_password')
    $signing_server_ssl_cert     = $config::signing_server_ssl_certs[$hostname] ? {
        undef => secret('signing_server_ssl_cert'),
        default => $config::signing_server_ssl_certs[$hostname],
    }
    $signing_server_ssl_private_key = $config::signing_server_ssl_private_keys[$hostname] ? {
        undef => secret('signing_server_ssl_private_key'),
        default => $config::signing_server_ssl_private_keys[$hostname],
    }

    case $config::org {
        moco: {
            $signing_formats = $::operatingsystem ? {
                Darwin => ['dmg'],
                CentOS => ['gpg', 'sha2signcode', 'sha2signcodestub', 'sha2signcode-v2', 'sha2signcodestub-v2', 'mar', 'widevine', 'widevine_blessed']
            }
            $concurrency = $::macosx_productversion_major ? {
                10.9    => 6,
                default => 12
            }

            # This token auth is used for one-off partner repacks
            $moco_signing_server_repack_password = secret('moco_signing_server_repack_password')

            signingserver::instance {
                'dep-signing-server':
                    listenaddr          => '0.0.0.0',
                    port                => '9110',
                    code_tag            => 'SIGNING_SERVER',
                    mac_cert_subject_ou => 'Release Engineering',
                    token_secret        => secret('moco_signing_server_dep_token_secret'),
                    token_secret0       => secret('moco_signing_server_old_token_secret'),
                    new_token_auth      => "${signing_server_username}:${signing_server_dep_password}",
                    new_token_auth0     => "${signing_server_username}:${signing_server_dep_password}",
                    mar_key_name        => 'dep1',
                    formats             => $signing_formats,
                    signcode_timestamp  => 'no',
                    ssl_cert            => $signing_server_ssl_cert,
                    ssl_private_key     => $signing_server_ssl_private_key,
                    concurrency         => $concurrency;
            }
        }
        default: {
            fail("No signing server organization defined for ${org}")
        }
    }
}
