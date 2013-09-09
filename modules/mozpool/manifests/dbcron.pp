# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mozpool::dbcron {
    include packages::mysql

    $dbcron_sh = "/opt/mozpool/dbcron.sh"
    file {
        $dbcron_sh:
            content => template("mozpool/dbcron.sh.erb"),
            mode => 0755,
            show_diff => false;
    }
    if ($is_bmm_admin_host) {
        file {
            "/etc/cron.d/mozpool-dbcron":
                # run once a day
                content => "0 0 * * * apache $dbcron_sh\n";
        }
    } else {
        file {
            "/etc/cron.d/mozpool-dbcron":
                ensure => absent;
        }
    }
}
