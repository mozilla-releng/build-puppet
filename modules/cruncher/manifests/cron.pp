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
        '/etc/cron.d/allthethings':
            mode    => '0644',
            content => template('cruncher/allthethings_cron.erb');
        '/usr/local/bin/cert_check.sh':
            content => template('cruncher/cert_check.sh.erb'),
            mode    => '0755';
        '/etc/cron.weekly/check_sign_srv_ssl_exp.sh':
            mode    => '0755',
            content => template('cruncher/check_sign_srv_ssl_exp.sh.erb');
    }
}
