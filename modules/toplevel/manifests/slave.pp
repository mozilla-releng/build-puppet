# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# All buildbot slaves (both build and test) are subclasses of this class.

class toplevel::slave inherits toplevel::base {
    include disableservices::slave
    include puppet::atboot
    include sudoers::reboot
    include users::builder

    # apply tweaks
    include tweaks::dev_ptmx
    include tweaks::locale

    # *all* Darwin and Windows slaves need to autologin, not just testers
    if ($::operatingsystem == 'Darwin') or ($::operatingsystem == 'Windows') {
        include users::builder::autologin
    }
    # The initial pass for support for Win 7 and Win 10 is meant to only support secrets
    # This is temporarily here until we do full Puppet support for Win 7 or Win 10
    if ($::operatingsystem == Windows) {
        if ($::env_os_version != 2008) {
            include slave_secrets::relengapi_token
            include slave_secrets::crash_stats_api_token
            include mercurial::system_hgrc
            include mercurial::cacert
            include packages::mozilla::mozilla_maintenance_service
            include vnc
        }
    }
}
