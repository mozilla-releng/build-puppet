# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class slave_secrets::relengapi_token($ensure=present) {
    include config
    include dirs::builds
    $token_file = $::operatingsystem? {
      windows => 'c:/builds/relengapi.tok',
      default => '/builds/relengapi.tok'
  }

    if ($ensure == 'present' and $config::install_relengapi_token) {
        file {
            $token_file:
                content   => secret('slave_relengapi_token'),
                mode      => '0644',
                show_diff => false;
        }
    } else {
        file {
            $token_file:
                ensure => absent;
        }
    }
}
