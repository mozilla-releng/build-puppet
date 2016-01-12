# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class slave_secrets::release_s3_credentials($ensure=present) {
    include config
    include users::builder
    include dirs::builds

    $credentials_file = $::operatingsystem ? {
        windows => 'C:/builds/release-s3.credentials',
        default => "/builds/release-s3.credentials"
    }
    # These config files are for partner repacks. We don't do these repacks on Windows.
    $s3cfg_release = "/builds/release-s3cfg"
    $s3cfg_partners = "/builds/partners-s3cfg"

    case $::operatingsystem {
        CentOS, Darwin: {
            $environment = slavealloc_environment($clientcert)
            if ($environment == 'prod' and $slave_trustlevel == 'core') {
                $credentials_content = secret('release_s3_credentials_prod')
                $s3cfg_release_content = secret('release_s3cfg')
                $s3cfg_partners_content = secret('partners_s3cfg')
                $_ensure = $ensure
            } elsif ($environment == 'dev/pp') {
                $credentials_content = secret('release_s3_credentials_staging')
                $_ensure = $ensure
            } else {
                $_ensure = absent
            }
        }
        default: {
            $_ensure = absent
        }
    }

    # $ensure limits to builders (modules/slave_secrets/manifests/init.pp)
    # $_ensure further limits to Unix-style, non-try builders (case block above)
    # install_release_s3_credentials requires explicit enable (manifests/moco-config.pp)
    if ($_ensure == 'present' and $config::install_release_s3_credentials) {
        file {
            $credentials_file:
                content => $credentials_content,
                owner  => $::users::builder::username,
                group  => $::users::builder::group,
                mode    => 0600,
                show_diff => false;
        }
        file {
            $s3cfg_release:
                content => $s3cfg_release_content,
                owner  => $::users::builder::username,
                group  => $::users::builder::group,
                mode    => 0600,
                show_diff => false;
        }
        file {
            $s3cfg_partners:
                content => $s3cfg_partners_content,
                owner  => $::users::builder::username,
                group  => $::users::builder::group,
                mode    => 0600,
                show_diff => false;
        }
    } else {
        file {
            $credentials_file:
                ensure => absent;
        }
        file {
            $s3cfg_release:
                ensure => absent;
        }
        file {
            $s3cfg_partners:
                ensure => absent;
        }
    }
}
