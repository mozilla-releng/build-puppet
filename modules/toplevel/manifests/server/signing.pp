# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class toplevel::server::signing inherits toplevel::server {
    include config
    include ::security

    $signing_server_username         = secret('signing_server_username')
    $signing_server_dep_password     = secret('signing_server_dep_password')
    $signing_server_release_password = secret('signing_server_release_password')
    $signing_server_nightly_password = secret('signing_server_nightly_password')
    $signing_server_ssl_cert     = $config::signing_server_ssl_certs[$fqdn] ? {
        undef => secret('signing_server_ssl_cert'),
        default => $config::signing_server_ssl_certs[$fqdn],
    }
    $signing_server_ssl_private_key = $config::signing_server_ssl_private_keys[$fqdn] ? {
        undef => secret('signing_server_ssl_private_key'),
        default => $config::signing_server_ssl_private_keys[$fqdn],
    }

    assert {
      'signing-server-maximum-security':
        condition => $::security::maximum;
    }

    case $config::org {
        moco: {
            $signing_formats = $::operatingsystem ? {
                Darwin => ['dmg'],
                CentOS => ['gpg', 'sha2signcode', 'sha2signcodestub', 'osslsigncode', 'signcode', 'mar', 'mar_sha384', 'jar', 'emevoucher', 'widevine', 'widevine_blessed']
            }
            $concurrency = $::macosx_productversion_major ? {
                10.9    => 2,
                10.10   => 2,
                default => 4
            }

            # This token auth is used for one-off partner repacks
            $moco_signing_server_repack_password = secret('moco_signing_server_repack_password')

            signingserver::instance {
                'nightly-key-signing-server':
                    listenaddr          => '0.0.0.0',
                    port                => '9100',
                    code_tag            => 'SIGNING_SERVER',
                    # The OU on the Developer ID certificates is set to a random-ish string
                    # that is consistent for all certs from the same account.
                    mac_cert_subject_ou => '43AQ936H96',
                    token_secret        => secret('moco_signing_server_nightly_token_secret'),
                    token_secret0       => secret('moco_signing_server_old_token_secret'),
                    new_token_auth      => "${signing_server_username}:${signing_server_nightly_password}",
                    new_token_auth0     => "${signing_server_username}:${signing_server_nightly_password}",
                    mar_key_name        => 'nightly1',
                    mar_sha384_key_name => 'nightly1',
                    jar_key_name        => 'nightly',
                    jar_digestalg       => 'SHA1',
                    jar_sigalg          => 'SHA1withDSA',
                    formats             => $signing_formats,
                    ssl_cert            => $signing_server_ssl_cert,
                    ssl_private_key     => $signing_server_ssl_private_key,
                    concurrency         => $concurrency;
            }

            signingserver::instance {
                'dep-key-signing-server':
                    listenaddr          => '0.0.0.0',
                    port                => '9110',
                    code_tag            => 'SIGNING_SERVER',
                    mac_cert_subject_ou => 'Release Engineering',
                    token_secret        => secret('moco_signing_server_dep_token_secret'),
                    token_secret0       => secret('moco_signing_server_old_token_secret'),
                    new_token_auth      => "${signing_server_username}:${signing_server_dep_password}",
                    new_token_auth0     => "${signing_server_username}:${signing_server_dep_password}",
                    mar_key_name        => 'dep1',
                    mar_sha384_key_name => 'dep1',
                    jar_key_name        => 'dep',
                    jar_digestalg       => 'SHA1',
                    jar_sigalg          => 'SHA1withRSA',
                    formats             => $signing_formats,
                    signcode_timestamp  => 'no',
                    ssl_cert            => $signing_server_ssl_cert,
                    ssl_private_key     => $signing_server_ssl_private_key,
                    concurrency         => $concurrency,
                    # We need to allow very large files to be signed for code
                    # coverage builds
                    signcode_maxsize    => 786432000;
            }

            $release_signing_formats = $::operatingsystem ? {
                Darwin => $signing_formats,
                # Linux release signing servers can handle focus signing.
                # XXX Sadly in puppet, there is no way to append to an existing array defined in the same scope.
                # That's why the array is duplicated with the added formats on the second line.
                CentOS => [
                    'gpg', 'sha2signcode', 'sha2signcodestub', 'osslsigncode', 'signcode', 'mar', 'mar_sha384', 'jar', 'emevoucher', 'widevine', 'widevine_blessed',
                    'focus-jar',
                ],
            }
            signingserver::instance {
                'rel-key-signing-server':
                    listenaddr          => '0.0.0.0',
                    port                => '9120',
                    code_tag            => 'SIGNING_SERVER',
                    # The OU on the Developer ID certificates is set to a random-ish string
                    # that is consistent for all certs from the same account.
                    mac_cert_subject_ou => '43AQ936H96',
                    token_secret        => secret('moco_signing_server_release_token_secret'),
                    token_secret0       => secret('moco_signing_server_old_token_secret'),
                    new_token_auth      => "${signing_server_username}:${signing_server_release_password}",
                    new_token_auth0     => "${signing_server_username}:${moco_signing_server_repack_password}",
                    mar_key_name        => 'rel1',
                    mar_sha384_key_name => 'rel1',
                    jar_key_name        => 'release',
                    jar_digestalg       => 'SHA1',
                    jar_sigalg          => 'SHA1withRSA',
                    focus_jar_key_name  => 'focus',
                    focus_jar_digestalg => 'SHA-256',
                    focus_jar_sigalg    => 'SHA256withRSA',
                    formats             => $release_signing_formats,
                    ssl_cert            => $signing_server_ssl_cert,
                    ssl_private_key     => $signing_server_ssl_private_key,
                    concurrency         => $concurrency;
            }
        }
        relabs: {
            $signing_formats = $::operatingsystem ? {
                Darwin => ['gpg', 'dmg', 'mar'],
                CentOS => ['gpg', 'signcode', 'mar', 'mar_sha384', 'jar']
            }

            signingserver::instance {
                'relabs-signing-server-1':
                    listenaddr          => '0.0.0.0',
                    port                => '9100',
                    code_tag            => 'SIGNING_SERVER',
                    mac_cert_subject_ou => 'RELABS RELABS RELABS',
                    token_secret        => secret('relabs_signing_server_token_secret'),
                    token_secret0       => secret('relabs_signing_server_token_secret'),
                    new_token_auth      => "${signing_server_username}:${signing_server_dep_password}",
                    new_token_auth0     => "${signing_server_username}:${signing_server_dep_password}",
                    mar_key_name        => 'relabs1',
                    mar_sha384_key_name => 'relabs1',
                    jar_key_name        => 'relabs',
                    jar_digestalg       => 'SHA1',
                    jar_sigalg          => 'SHA1withDSA',
                    formats             => $signing_formats,
                    ssl_cert            => secret('relabs_signing_server_ssl_cert'),
                    ssl_private_key     => secret('relabs_signing_server_ssl_private_key');
            }
        }
        default: {
            fail("no signing server organization defined for ${::org}")
        }
    }
}
