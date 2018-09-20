# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class signing_server_cert_check::cron {
    file {
        '/usr/local/bin/cert_check.sh':
            source => 'puppet:///modules/signing_server_cert_check/cert_check.sh',
            mode   => '0755';
        '/etc/cron.weekly/check_sign_srv_ssl_exp.sh':
            source => 'puppet:///modules/signing_server_cert_check/check_sign_srv_ssl_exp.sh',
            mode   => '0755';
    }
}
