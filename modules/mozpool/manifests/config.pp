# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mozpool::config {
    include mozpool::settings

    file {
        $mozpool::settings::config_ini:
            content => template("mozpool/config.ini.erb"),
            mode => 0755,
            show_diff => false;
    }

    # put that in an env var in the global profile
    shellprofile::file {
        "mozpool_config":
            content => "export MOZPOOL_CONFIG=$mozpool::settings::config_ini";
    }
}
