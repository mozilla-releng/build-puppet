# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class slave_secrets::google_api_key($ensure=present) {
    include config
    include dirs::builds

    if ($ensure == 'present' and $config::install_google_api_key) {
        file {
            "/builds/gapi.data":
                content => secret("google_api_key"),
                mode    => 0644,
                show_diff => false;
        }
    } else {
        file {
            "/builds/gapi.data":
                ensure => absent;
        }
    }
}
