# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class duo {

    # When $duo_enabled is set true, duo will be enabled on the host
    # If set to false or undef, it will ensure duo is disabled on the host
    # $duo_enabled is a node-scope variable

    $_duo_enabled = $duo_enabled ? {
        true    => true,
        default => false,
    }

    if (secret('duo_ikey') == '' or secret('duo_skey') == '' or secret('duo_host') == '') {
        fail('Missing duo secrets')
    }

    class { 'duo::duo_unix':
        enabled  => $_duo_enabled,
        ikey     => secret('duo_ikey'),
        skey     => secret('duo_skey'),
        host     => secret('duo_host'),
        pushinfo => 'yes',
    }

}
