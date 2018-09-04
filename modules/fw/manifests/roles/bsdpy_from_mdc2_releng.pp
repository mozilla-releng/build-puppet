# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class fw::roles::bsdpy_from_mdc2_releng {
    include fw::networks

    # Technicially it's BSDP. See https://static.afp548.com/mactips/bootpd.html
    fw::rules { 'allow_dhcp_from_mdc2_releng':
        sources => $::fw::networks::mdc2_releng,
        app     => 'dhcp_server'
    }
    # TFTP so client can get booter file
    fw::rules { 'allow_tftp_from_mdc2_releng':
        sources => $::fw::networks::mdc2_releng,
        app     => 'tftp'
    }
    # Used if NBI is set to netboot via http
    fw::rules { 'allow_http_from_mdc2_releng':
        sources => $::fw::networks::mdc2_releng,
        app     => 'http'
    }
}
