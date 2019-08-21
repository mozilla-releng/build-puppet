# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class collectd::disable {
    include collectd::settings

    # collectd must be installed for the service to be stopped and disabled
    include packages::collectd

    service {
        $collectd::settings::servicename:
            ensure     => stopped,
            enable     => false,
            hasstatus  => true,
            hasrestart => true,
    }
}
