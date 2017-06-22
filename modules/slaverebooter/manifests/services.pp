# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class slaverebooter::services {
    include ::config
    include users::builder
    include slaverebooter::settings
    include packages::procmail # for lockfile

    $owner   = $users::builder::username
    $basedir = $slaverebooter::settings::root
    $config  = $slaverebooter::settings::config
    file {
        '/etc/cron.d/slaverebooter':
            require => Python::Virtualenv[$basedir],
            mode    => '0600',
            content => template('slaverebooter/cron.erb');
    }
}
