# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class fw::roles::buildbot_master_from_various {
    include fw::networks

    # Allow buildbot rpc from all slaves and other bb masters
    fw::rules { 'allow_buildbot_rpc':
        sources =>  [ $::fw::networks::all_bb_slaves,
                      $::fw::networks::all_bb_masters ],
        app     => 'buildbot_rpc_range'
    }
    # Allow buildbot http from other bb masters, slaveapi,
    # infra corp jumphost, infra vpn users and buildduty tools
    fw::rules { 'allow_buildbot_http':
        sources =>  [ $::fw::networks::all_bb_masters,
                      $::fw::networks::slaveapi,
                      $::fw::networks::infra_corp_jumphost,
                      $::fw::networks::infra_vpn_users,
                      $::fw::networks::buildduty_tools ],
        app     => 'buildbot_http_range'
    }
    # Allow bb related ssh from other bb masters and buildduty tools
    fw::rules { 'allow_buildbot_ssh':
        sources =>  [ $::fw::networks::all_bb_masters,
                      $::fw::networks::buildduty_tools ],
        app     => 'ssh'
    }
}
