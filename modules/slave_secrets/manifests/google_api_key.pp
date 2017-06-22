# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class slave_secrets::google_api_key($ensure=present) {
    include config
    include dirs::builds
    $gapi_file = $::operatingsystem? {
      windows => 'c:/builds/gapi.data',
      default => '/builds/gapi.data'
  }

    if ($ensure == 'present' and $config::install_google_api_key) {
        file {
            $gapi_file:
                content   => secret('google_api_key'),
                mode      => '0644',
                show_diff => false;
        }
    } else {
        file {
            $gapi_file:
                ensure => absent;
        }
    }
}

