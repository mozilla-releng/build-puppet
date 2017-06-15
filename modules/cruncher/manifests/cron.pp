# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class cruncher::cron {
    include users::buildduty
    include packages::mozilla::py27_mercurial

    file {
        '/etc/cron.d/slave_health':
            mode    => '0644',
            content => template('cruncher/slave_health_cron.erb');
        '/etc/cron.d/reportor':
            mode    => '0644',
            content => template('cruncher/reportor_cron.erb');
        '/etc/cron.d/allthethings':
            mode    => '0644',
            content => template('cruncher/allthethings_cron.erb');
    }
}
