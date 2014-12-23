# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class slave_secrets::mozilla_api_key($ensure=present) {
    include config
    include dirs::builds

    $mozilla_api_key = $::operatingsystem ? {
        Windows => 'C:/builds/mozilla-api.key',
        default => "/builds/mozilla-api.key"
    }
       
    if ($ensure == 'present' and $config::install_mozilla_api_key) {
        file {
            $mozilla_api_key:
                content => secret("mozilla_api_key"),
                mode    => 0644,
                show_diff => false;
        }
    } else {
        file {
            $mozilla_api_key:
                ensure => absent;
        }
    }
}
