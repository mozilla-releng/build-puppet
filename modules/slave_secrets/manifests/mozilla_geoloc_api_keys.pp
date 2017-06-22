# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class slave_secrets::mozilla_geoloc_api_keys($ensure=present) {
    include config
    include dirs::builds

    $api_key_path = $::operatingsystem ? {
        Windows => 'C:/builds',
        default => '/builds',
    }

    if ($ensure == 'present' and $config::install_mozilla_geoloc_api_keys) {
        file {
            # For compatibility; this can go away when bug 1113606 is fixed
            "${api_key_path}/mozilla-api.key":
                content   => secret('mozilla_fennec_geoloc_api_key'),
                mode      => '0644',
                show_diff => false;
            "${api_key_path}/mozilla-fennec-geoloc-api.key":
                content   => secret('mozilla_fennec_geoloc_api_key'),
                mode      => '0644',
                show_diff => false;
            "${api_key_path}/mozilla-desktop-geoloc-api.key":
                content   => secret('mozilla_desktop_geoloc_api_key'),
                mode      => '0644',
                show_diff => false;
        }
    } else {
        file {
            "${api_key_path}/mozilla-api.key":
                ensure => absent;
            "${api_key_path}/mozilla-fennec-geoloc-api.key":
                ensure => absent;
            "${api_key_path}/mozilla-desktop-geoloc-api.key":
                ensure => absent;
        }
    }
}
