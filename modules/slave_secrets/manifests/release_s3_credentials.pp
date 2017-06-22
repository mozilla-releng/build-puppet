# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class slave_secrets::release_s3_credentials($ensure=present) {
    include config
    include users::builder
    include dirs::builds

    $credentials_file = $::operatingsystem ? {
        windows => 'C:/builds/release-s3.credentials',
        default => '/builds/release-s3.credentials'
    }
    # release promotion s3 candidates creds
    $beetmover_credentials_file = $::operatingsystem ? {
        windows => 'C:/builds/beetmover-s3.credentials',
        default => '/builds/beetmover-s3.credentials'
    }
    $dev_beetmover_credentials_file = $::operatingsystem ? {
        windows => 'C:/builds/dev-beetmover-s3.credentials',
        default => '/builds/dev-beetmover-s3.credentials'
    }
    # These config files are for partner repacks. While we don't do these
    # repacks on Windows, they need to be a proper file resource.
    $s3cfg_release = $::operatingsystem ? {
        windows => 'C:/builds/release-s3cfg',
        default => '/builds/release-s3cfg'
    }
    $s3cfg_partners = $::operatingsystem ? {
        windows => 'C:/builds/partners-s3cfg',
        default => '/builds/partners-s3cfg'
    }

    case $::operatingsystem {
        CentOS, Darwin: {
            $environment = slavealloc_environment($clientcert)
            if ($environment == 'prod' and $slave_trustlevel == 'core') {
                $credentials_content               = secret('release_s3_credentials_prod')
                # dev/prod is decided by taskcluster not by buildbot slave type
                $beetmover_credentials_content     = secret('beetmover_s3_credentials_file')
                $dev_beetmover_credentials_content = secret('dev_beetmover_s3_credentials_file')
                $s3cfg_release_content             = secret('release_s3cfg')
                $s3cfg_partners_content            = secret('partners_s3cfg')
                $_ensure = $ensure
            } elsif ($environment == 'dev/pp') {
                $credentials_content               = secret('release_s3_credentials_staging')
                $_ensure                           = $ensure
            } else {
                $_ensure                           = absent
            }
        }
        default: {
            $_ensure                               = absent
        }
    }

    # $ensure limits to builders (modules/slave_secrets/manifests/init.pp)
    # $_ensure further limits to Unix-style, non-try builders (case block above)
    # install_release_s3_credentials requires explicit enable (manifests/moco-config.pp)
    if ($_ensure == 'present' and $config::install_release_s3_credentials) {
        file {
            $credentials_file:
                content   => $credentials_content,
                owner     => $::users::builder::username,
                group     => $::users::builder::group,
                mode      => '0600',
                show_diff => false;
        }
        file {
            $beetmover_credentials_file:
                content   => $beetmover_credentials_content,
                owner     => $::users::builder::username,
                group     => $::users::builder::group,
                mode      => '0600',
                show_diff => false;
        }
        file {
            $dev_beetmover_credentials_file:
                content   => $dev_beetmover_credentials_content,
                owner     => $::users::builder::username,
                group     => $::users::builder::group,
                mode      => '0600',
                show_diff => false;
        }
        file {
            $s3cfg_release:
                content   => $s3cfg_release_content,
                owner     => $::users::builder::username,
                group     => $::users::builder::group,
                mode      => '0600',
                show_diff => false;
        }
        file {
            $s3cfg_partners:
                content   => $s3cfg_partners_content,
                owner     => $::users::builder::username,
                group     => $::users::builder::group,
                mode      => '0600',
                show_diff => false;
        }
    } else {
        file {
            $credentials_file:
                ensure => absent;
        }
        file {
            $beetmover_credentials_file:
                ensure => absent;
        }
        file {
            $dev_beetmover_credentials_file:
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
