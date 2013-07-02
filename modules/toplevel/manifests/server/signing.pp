# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class toplevel::server::signing inherits toplevel::server {
    include config

    $signing_server_username = secret('signing_server_username')
    $signing_server_dep_password = secret('signing_server_dep_password')
    $signing_server_release_password = secret('signing_server_release_password')
    $signing_server_nightly_password = secret('signing_server_nightly_password')

    case $config::org {
        moco: {
            $signing_formats = $operatingsystem ? {
                Darwin => ["gpg", "dmg", "mar"],
                CentOS => ["gpg", "signcode", "mar", "jar", "b2gmar"]
            }

            # This token auth is used for one-off partner repacks
            $moco_signing_server_repack_password = secret('moco_signing_server_repack_password')

            signingserver::instance {
                "nightly-key-signing-server":
                    listenaddr     => "0.0.0.0",
                    port           => "9100",
                    code_tag       => "SIGNING_SERVER",
                    # The OU on the Developer ID certificates is set to a random-ish string
                    # that is consistent for all certs from the same account.
                    mac_cert_subject_ou => "43AQ936H96",
                    token_secret   => secret('moco_signing_server_nightly_token_secret'),
                    token_secret0  => secret('moco_signing_server_old_token_secret'),
                    new_token_auth => "${signing_server_username}:${signing_server_nightly_password}",
                    new_token_auth0=> "${signing_server_username}:${signing_server_nightly_password}",
                    mar_key_name   => "nightly1",
                    jar_key_name   => "nightly",
                    b2g_key0       => "test-oem-1",
                    b2g_key1       => "test-carrier-1",
                    b2g_key2       => "test-mozilla-1",
                    formats        => $signing_formats;
            }

            signingserver::instance {
                "dep-key-signing-server":
                    listenaddr     => "0.0.0.0",
                    port           => "9110",
                    code_tag       => "SIGNING_SERVER",
                    mac_cert_subject_ou => "Release Engineering",
                    token_secret   => secret('moco_signing_server_dep_token_secret'),
                    token_secret0  => secret('moco_signing_server_old_token_secret'),
                    new_token_auth => "${signing_server_username}:${signing_server_dep_password}",
                    new_token_auth0=> "${signing_server_username}:${signing_server_dep_password}",
                    mar_key_name   => "dep1",
                    jar_key_name   => "nightly",
                    b2g_key0       => "test-oem-1",
                    b2g_key1       => "test-carrier-1",
                    b2g_key2       => "test-mozilla-1",
                    formats        => $signing_formats,
                    signcode_timestamp => "no";
            }
            signingserver::instance {
                "rel-key-signing-server":
                    listenaddr     => "0.0.0.0",
                    port           => "9120",
                    code_tag       => "SIGNING_SERVER",
                    # The OU on the Developer ID certificates is set to a random-ish string
                    # that is consistent for all certs from the same account.
                    mac_cert_subject_ou => "43AQ936H96",
                    token_secret   => secret('moco_signing_server_release_token_secret'),
                    token_secret0  => secret('moco_signing_server_old_token_secret'),
                    new_token_auth => "${signing_server_username}:${signing_server_release_password}",
                    new_token_auth0=> "${signing_server_username}:${moco_signing_server_repack_password}",
                    mar_key_name   => "rel1",
                    jar_key_name   => "release",
                    b2g_key0       => "test-oem-1",
                    b2g_key1       => "test-carrier-1",
                    b2g_key2       => "test-mozilla-1",
                    formats        => $signing_formats;
            }
        }
        relabs: {
            $signing_formats = $operatingsystem ? {
                Darwin => ["gpg", "dmg", "mar"],
                CentOS => ["gpg", "signcode", "mar", "jar", "b2gmar"]
            }

            signingserver::instance {
                "relabs-signing-server-1":
                    listenaddr     => "0.0.0.0",
                    port           => "9100",
                    code_tag       => "SIGNING_SERVER",
                    mac_cert_subject_ou => "RELABS RELABS RELABS",
                    token_secret   => secret('relabs_signing_server_token_secret'),
                    token_secret0  => secret('relabs_signing_server_token_secret'),
                    new_token_auth => "${signing_server_username}:${signing_server_dep_password}",
                    new_token_auth0=> "${signing_server_username}:${signing_server_dep_password}",
                    mar_key_name   => "relabs1",
                    jar_key_name   => "relabs",
                    b2g_key0       => "relabs-oem-1",
                    b2g_key1       => "relabs-carrier-1",
                    b2g_key2       => "relabs-mozilla-1",
                    formats        => $signing_formats;
            }
        }
        default: {
            fail("no signing server organization defined for $org")
        }
    }
}
