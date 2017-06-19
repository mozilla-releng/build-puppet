# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class l10n_bumper::services {
    include ::config
    include users::builder
    include l10n_bumper::settings
    include packages::mozilla::python27
    include packages::procmail # for lockfile

    $env_config  = $config::l10n_bumper_env_config[$l10n_bumper_env]

    $owner       = $users::builder::username
    $basedir     = $l10n_bumper::settings::root
    $python      = $packages::mozilla::python27::python
    $mailto      = $l10n_bumper::settings::mailto
    $config_file = $env_config['config_file']
    file {
        '/etc/cron.d/l10n_bumper':
            require => File["${basedir}/download_mozharness.sh"],
            mode    => '0600',
            content => template('l10n_bumper/cron.erb');
    }
}
