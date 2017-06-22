# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla..org/MPL/2.0/.

class slave_secrets::adjust_sdk_token($ensure=present) {
    include config
    include users::builder
    include dirs::builds

    $adjust_sdk_token      = $::operatingsystem ? {
        windows => 'C:/builds/adjust-sdk.token',
        default => '/builds/adjust-sdk.token'
    }
    $adjust_sdk_beta_token = $::operatingsystem ? {
        windows => 'C:/builds/adjust-sdk-beta.token',
        default => '/builds/adjust-sdk-beta.token'
    }


    if ($ensure == 'present' and $config::install_adjust_sdk_token) {
        case $::operatingsystem {
            # We only (currently) install the Adjust SDK on CentOS for
            # copying into the mock environment for Android builds.
            CentOS: {
                file {
                    $adjust_sdk_token:
                        content   => secret('adjust_sdk_token'),
                        owner     => $::users::builder::username,
                        group     => $::users::builder::group,
                        mode      => '0600',
                        show_diff => false;
                    $adjust_sdk_beta_token:
                        content   => secret('adjust_sdk_beta_token'),
                        owner     => $::users::builder::username,
                        group     => $::users::builder::group,
                        mode      => '0600',
                        show_diff => false;
                }
            }
            default: {
                file {
                    $adjust_sdk_token:
                        ensure => absent;
                    $adjust_sdk_beta_token:
                        ensure => absent;
                }
            }
        }
    } else {
        file {
            $adjust_sdk_token:
                ensure => absent;
            $adjust_sdk_beta_token:
                ensure => absent;
        }
    }
}
