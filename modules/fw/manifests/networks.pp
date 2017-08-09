# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class fw::networks {

    # Everywhere
    $everywhere = [ '0.0.0.0/0' ]

    # Data Center CIDRs
    $scl3_releng = [ '10.26.0.0/16' ]
    $mdc1_releng = [ '10.49.0.0/16' ]
    $mdc2_releng = [ '10.51.0.0/16' ]

    # AWS VPC CIDRs
    $use1_releng = [ '10.134.0.0/16' ]
    $usw2_releng = [ '10.132.0.0/16' ]

    # SCL3 Network CIDRs
    $bb_scl3      = [ '10.26.68.0/24' ] # *.bb.releng.scl3.mozilla.com
    $build_scl3   = [ '10.26.52.0/22' ] # *.build.releng.scl3.mozilla.com
    $inband_scl3  = [ '10.26.16.0/22' ] # *.inband.releng.scl3.mozilla.com
    $srv_scl3     = [ '10.26.48.0/22' ] # *.srv.releng.scl3.mozilla.com
    $test_scl3    = [ '10.26.56.0/22' ] # *.test.releng.scl3.mozilla.com
    $try_scl3     = [ '10.26.64.0/22' ] # *.try.releng.scl3.mozilla.com
    $wintest_scl3 = [ '10.26.40.0/22' ] # *.wintest.releng.scl3.mozilla.com

    # USE1 Network CIDRs
    $bb_use1 = [ '10.134.68.0/22' ] # *.bb.releng.use1.mozilla.com

    # USW2 Network CIDRs
    $bb_usw2 = [ '10.132.68.0/22' ] # *.bb.releng.use1.mozilla.com

    #
    # Logical groups of hosts
    #

    $all_releng = [ $scl3_releng, $mdc1_releng, $mdc2_releng, $use1_releng, $usw2_releng ]

    $non_distingushed_puppetmasters = [ '10.26.48.45/32',  # releng-puppet1.srv.releng.scl3.mozilla.com
                                        '10.134.48.16/32', # releng-puppet1.srv.releng.use1.mozilla.com
                                        '10.132.48.16/32', # releng-puppet1.srv.releng.usw2.mozilla.com
                                        '10.49.48.21/32',  # releng-puppet1.srv.releng.mdc1.mozilla.com
                                        '10.49.48.22/32' ] # releng-puppet2.srv.releng.mdc1.mozilla.com

    $distingushed_puppetmaster = [ '10.26.48.50/32' ] # releng-puppet2.srv.releng.scl3.mozilla.com

    $infra_bacula_scl3 = [ '10.22.8.141/32' ] # bacula1.private.scl3.mozilla.com
    $infra_bacula_mdc1 = [ '10.48.8.141/32' ] # bacula1.private.mdc1.mozilla.com

    # Jumphosts

    # SCL3 Jumphosts
    $scl3_rejh = [ '10.26.48.19/32', '10.26.48.20/32' ]   # rejhi[1,2].srv.releng.scl3.mozilla.com

    # MDC1 Jumphosts
    $mdc1_rejh = [ '10.49.48.100/32', '10.49.48.101/32' ] # rejhi[1,2].srv.releng.mdc1.mozilla.com

    # ALL Jumphosts
    $rejh      = [ $scl3_rejh,  $mdc1_rejh ]

    # Nagios hosts
    $nagios = [ '10.26.75.30/32',  # nagios1.private.releng.scl3.mozilla.com
                '10.49.75.30/32' ] # nagios1.private.releng.mdc1.mozilla.com.


    # Infra VPN Network Endpoints (CIDR blocks of IPs given to vpn clients)

    # Infra SCL3 Jumphost (ssh.mozilla.com)

}
