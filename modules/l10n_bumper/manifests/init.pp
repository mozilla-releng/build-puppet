# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class l10n_bumper {
    include ::config
    include dirs::builds
    include users::builder
    include l10n_bumper::settings
    include l10n_bumper::services
    include packages::mozilla::python27

    $env_config          = $config::l10n_bumper_env_config[$l10n_bumper_env]

    $root                = $l10n_bumper::settings::root
    $share_base          = $l10n_bumper::settings::share_base
    $mozharness_repo     = $env_config['mozharness_repo']
    $mozharness_revision = $env_config['mozharness_revision']

    file {
        $root:
            ensure => directory,
            mode   => '0755',
            owner  => $::users::builder::username,
            group  => $::users::builder::group;
        $share_base:
            ensure => directory,
            mode   => '0755',
            owner  => $::users::builder::username,
            group  => $::users::builder::group;
        "${root}/download_mozharness.sh":
            require => File[$root],
            mode    => '0755',
            owner   => $::users::builder::username,
            group   => $::users::builder::group,
            content => template('l10n_bumper/download_mozharness.sh.erb'),
            notify  => Exec['download_mozharness'];
    }

    exec {
        # download mozharness
        'download_mozharness':
            require => File["${root}/download_mozharness.sh"],
            command => "${root}/download_mozharness.sh",
            user    => $::users::builder::username;
    }

}
