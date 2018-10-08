# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class fw::networks {

    # Everywhere
    $everywhere = [ '0.0.0.0/0' ]

    # Data Center CIDRs
    $mdc1_releng = [ '10.49.0.0/16' ]
    $mdc2_releng = [ '10.51.0.0/16' ]

    # AWS VPC CIDRs
    $use1_releng = [ '10.134.0.0/16' ]
    $usw2_releng = [ '10.132.0.0/16' ]

    # MDC1 Releng Network CIDRs
    $ops_mdc1     = [ '10.49.8.0/21' ]  # *.ops.releng.mdc1.mozilla.com
    $inband_mdc1  = [ '10.49.16.0/22' ] # *.inband.releng.mdc1.mozilla.com
    $wintest_mdc1 = [ '10.49.40.0/22' ] # *.wintest.releng.mdc1.mozilla.com
    $srv_mdc1     = [ '10.49.48.0/24' ] # *.srv.releng.mdc1.mozilla.com
    $test_mdc1    = [ '10.49.56.0/22' ] # *.test.releng.mdc1.mozilla.com
    $private_mdc1 = [ '10.49.75.0/24' ] # *.private.releng.mdc1.mozilla.com
    $relabs_mdc1  = [ '10.49.78.0/24' ] # *.relabs.releng.mdc1.mozilla.com

    # MDC2 Releng Network CIDRs
    $ops_mdc2     = [ '10.51.8.0/21' ]  # *.ops.releng.mdc2.mozilla.com
    $inband_mdc2  = [ '10.51.16.0/22' ] # *.inband.releng.mdc2.mozilla.com
    $wintest_mdc2 = [ '10.51.40.0/22' ] # *.wintest.releng.mdc2.mozilla.com
    $srv_mdc2     = [ '10.51.48.0/24' ] # *.srv.releng.mdc2.mozilla.com
    $test_mdc2    = [ '10.51.56.0/22' ] # *.test.releng.mdc2.mozilla.com
    $private_mdc2 = [ '10.51.75.0/24' ] # *.private.releng.mdc2.mozilla.com
    $relabs_mdc2  = [ '10.51.78.0/24' ] # *.relabs.releng.mdc2.mozilla.com

    # AWS Networks; See https://github.com/mozilla-releng/build-cloud-tools/blob/master/configs/subnets.yml

    # USE1 Network CIDRs
    $use1_srv     = [ '10.134.48.0/22' ]
    $use1_bb      = [ '10.134.68.0/26', '10.134.68.64/26', '10.134.68.128/26', '10.134.68.192/26' ]
    $use1_signing = [ '10.134.30.0/24' ]

    # USW2 Network CIDRs
    $usw2_srv     = [ '10.132.48.0/22' ]
    $usw2_bb      = [ '10.132.68.0/26', '10.132.68.64/26', '10.132.68.128/26', '10.132.68.192/26' ]
    $usw2_signing = [ '10.132.30.0/24' ]

    #
    # Logical groups of hosts
    #

    # All releng subnets
    $all_releng = [ $mdc1_releng, $mdc2_releng, $use1_releng, $usw2_releng ]

    # All buildbot master subnets
    $all_bb_masters = [ $use1_bb, $usw2_bb ]

    $dc_test   = [ $test_mdc1, $wintest_mdc1, $test_mdc2, $wintest_mdc2 ]

    $buildduty_tools = [ '10.132.51.74/32' ] # buildduty-tools.srv.releng.usw2.mozilla.com

    $roller = [ '10.49.48.75/32',  # roller1.srv.releng.mdc1.mozilla.com
                '10.49.48.76/32',  # roller-dev1.srv.releng.mdc1.mozilla.com
                '10.51.48.75/32',  # roller1.srv.releng.mdc2.mozilla.com
                '10.51.48.76/32' ] # roller-dev1.srv.releng.mdc2.mozilla.com

    $non_distingushed_puppetmasters = [ '10.134.48.16/32', # releng-puppet1.srv.releng.use1.mozilla.com
                                        '10.132.48.16/32', # releng-puppet1.srv.releng.usw2.mozilla.com
                                        '10.49.48.21/32',  # releng-puppet1.srv.releng.mdc1.mozilla.com
                                        '10.49.48.22/32',  # releng-puppet2.srv.releng.mdc1.mozilla.com
                                        '10.51.48.21/32',  # releng-puppet1.srv.releng.mdc2.mozilla.com
                                        '10.51.48.22/32' ] # releng-puppet2.srv.releng.mdc2.mozilla.com

    $distingushed_puppetmaster = [ '10.49.48.22/32' ] # releng-puppet2.srv.releng.mdc1.mozilla.com

    $infra_bacula_mdc1 = [ '10.48.75.200/32' ] # bacula1.private.mdc1.mozilla.com
    $infra_bacula_mdc2 = [ '10.50.75.200/32' ] # bacula1.private.mdc2.mozilla.com

    # Jumphosts

    # MDC1 Jumphosts
    $mdc1_rejh = [ '10.49.48.100/32', '10.49.48.101/32' ] # rejhi[1,2].srv.releng.mdc1.mozilla.com

    # MDC2 Jumphosts
    $mdc2_rejh = [ '10.51.48.100/32', '10.51.48.101/32' ] # rejhi[1,2].srv.releng.mdc2.mozilla.com

    # ALL Jumphosts
    $rejh      = [ $mdc1_rejh, $mdc2_rejh ]

    # Nagios hosts
    $nagios = [ '10.49.75.30/32',  # nagios1.private.releng.mdc1.mozilla.com
                '10.51.75.30/32' ] # nagios1.private.releng.mdc2.mozilla.com

    # NOTE: The signing server application also limits by IP
    # See $signing_allowed_ips in moco-config.pp

    # Dep signing workers
    $use1_dep_signing_workers = [ '10.134.30.231/32',  # depsigning-worker1.srv.releng.use1.mozilla.com
                                  '10.134.30.38/32',   # depsigning-worker3.srv.releng.use1.mozilla.com
                                  '10.134.30.130/32',  # depsigning-worker5.srv.releng.use1.mozilla.com
                                  '10.134.30.254/32',  # depsigning-worker7.srv.releng.use1.mozilla.com
                                  '10.134.30.159/32',  # depsigning-worker9.srv.releng.use1.mozilla.com
                                  '10.134.30.164/32',  # depsigning-worker11.srv.releng.use1.mozilla.com
                                  '10.134.30.103/32',  # depsigning-worker13.srv.releng.use1.mozilla.com
                                  '10.134.30.78/32',   # depsigning-worker15.srv.releng.use1.mozilla.com
                                  '10.134.30.109/32' ] # tb-depsigning-worker1.srv.releng.use1.mozilla.com

    $usw2_dep_signing_workers = [ '10.132.30.55/32',   # depsigning-worker2.srv.releng.usw2.mozilla.com
                                  '10.132.30.242/32',  # depsigning-worker4.srv.releng.usw2.mozilla.com
                                  '10.132.30.139/32',  # depsigning-worker6.srv.releng.usw2.mozilla.com
                                  '10.132.30.117/32',  # depsigning-worker8.srv.releng.usw2.mozilla.com
                                  '10.132.30.112/32',  # depsigning-worker10.srv.releng.usw2.mozilla.com
                                  '10.132.30.250/32',  # depsigning-worker12.srv.releng.usw2.mozilla.com
                                  '10.132.30.90/32',   # depsigning-worker14.srv.releng.usw2.mozilla.com
                                  '10.132.30.135/32' ] # depsigning-worker16.srv.releng.usw2.mozilla.com

    $all_dep_signing_workers = [ $use1_dep_signing_workers, $usw2_dep_signing_workers ]

    # Signing linux workers
    $use1_signing_linux_workers = [ '10.134.30.12/32',   # signing-linux-1.srv.releng.use1.mozilla.com
                                    '10.134.30.125/32',  # signing-linux-3.srv.releng.use1.mozilla.com
                                    '10.134.30.97/32',   # signing-linux-5.srv.releng.use1.mozilla.com
                                    '10.134.30.39/32',   # signing-linux-7.srv.releng.use1.mozilla.com
                                    '10.134.30.180/32',  # signing-linux-9.srv.releng.use1.mozilla.com
                                    '10.134.30.119/32',  # signing-linux-11.srv.releng.use1.mozilla.com
                                    '10.134.30.162/32',  # tb-signing-1.srv.releng.use1.mozilla.com
                                    '10.134.30.205/32',  # tb-signing-3.srv.releng.use1.mozilla.com
                                    '10.134.30.227/32',  # tb-signing-5.srv.releng.use1.mozilla.com
                                    '10.134.30.110/32',  # tb-signing-7.srv.releng.use1.mozilla.com
                                    '10.134.30.42/32',   # tb-signing-9.srv.releng.use1.mozilla.com
                                    '10.134.30.184/32' ] # mobil-signing-linux-1.srv.releng.use1.mozilla.com

    $usw2_signing_linux_workers = [ '10.132.30.46/32',   # signing-linux-2.srv.releng.usw2.mozilla.com
                                    '10.132.30.82/32',   # signing-linux-4.srv.releng.usw2.mozilla.com
                                    '10.132.30.182/32',  # signing-linux-6.srv.releng.usw2.mozilla.com
                                    '10.132.30.219/32',  # signing-linux-8.srv.releng.usw2.mozilla.com
                                    '10.132.30.166/32',  # signing-linux-10.srv.releng.usw2.mozilla.com
                                    '10.132.30.43/32',   # signing-linux-12.srv.releng.usw2.mozilla.com
                                    '10.132.30.120/32',  # signing-linux-13.srv.releng.usw2.mozilla.com
                                    '10.132.30.124/32',  # signing-linux-14.srv.releng.usw2.mozilla.com
                                    '10.132.30.144/32',  # signing-linux-15.srv.releng.usw2.mozilla.com
                                    '10.132.30.215/32',  # signing-linux-16.srv.releng.usw2.mozilla.com
                                    '10.132.30.77/32',   # signing-linux-17.srv.releng.usw2.mozilla.com
                                    '10.132.30.240/32',  # signing-linux-18.srv.releng.usw2.mozilla.com
                                    '10.132.30.253/32',  # signing-linux-19.srv.releng.usw2.mozilla.com
                                    '10.132.30.224/32',  # signing-linux-20.srv.releng.usw2.mozilla.com
                                    '10.132.30.20/32',   # signing-linux-21.srv.releng.usw2.mozilla.com
                                    '10.132.30.114/32',  # signing-linux-22.srv.releng.usw2.mozilla.com
                                    '10.132.30.76/32',   # tb-signing-2.srv.releng.usw2.mozilla.com
                                    '10.132.30.63/32',   # tb-signing-4.srv.releng.usw2.mozilla.com
                                    '10.132.30.163/32',  # tb-signing-6.srv.releng.usw2.mozilla.com
                                    '10.132.30.190/32',  # tb-signing-8.srv.releng.usw2.mozilla.com
                                    '10.132.30.206/32' ] # tb-signing-10.srv.releng.usw2.mozilla.com

    $all_signing_linux_workers = [ $use1_signing_linux_workers, $usw2_signing_linux_workers ]

    # Dev linux signing workers
    $dev_signing_linux_workers = [ '10.134.30.207/32' ] # signing-linux-dev1.srv.releng.use1.mozilla.com


    # Infra VPN Network Endpoints (CIDR blocks of IPs given to vpn clients)
    # See bug 1419983
    $infra_mdc1_vpn_users = [ '10.48.236.0/23',  # 10.48.236.0/23 (stage TCP) = 10-48-Y-Z.vpn-stage.mdc1.mozilla.com
                              '10.48.238.0/23',  # 10.48.238.0/23 (stage UDP) = 10-48-Y-Z.vpn-stage.mdc1.mozilla.com
                              '10.48.240.0/23',  # 10.48.240.0/23 (prod UDP)  = 10-48-Y-Z.vpn.mdc1.mozilla.com
                              '10.48.242.0/23' ] # 10.48.242.0/23 (prod TCP)  = 10-48-Y-Z.vpn.mdc1.mozilla.com

    $infra_mdc2_vpn_users = [ '10.50.236.0/23',  # 10.50.236.0/23 (stage TCP) = 10-50-Y-Z.vpn-stage.mdc2.mozilla.com
                              '10.50.238.0/23',  # 10.50.238.0/23 (stage UDP) = 10-50-Y-Z.vpn-stage.mdc2.mozilla.com
                              '10.50.240.0/23',  # 10.50.240.0/23 (prod UDP)  = 10-50-Y-Z.vpn.mdc2.mozilla.com
                              '10.50.242.0/23' ] # 10.50.242.0/23 (prod TCP)  = 10-50-Y-Z.vpn.mdc2.mozilla.com

    # All vpn endpoint ranges
    $infra_vpn_users =  [ $infra_mdc1_vpn_users, $infra_mdc2_vpn_users ]

    # Infra Jumphosts
    $infra_corp_jumphost = [  '10.48.72.100/32',  # ssh1.corpdmz.mdc1.mozilla.com
                              '10.50.72.100/32' ] # ssh1.corpdmz.mdc2.mozilla.com

    # mtv2 qa network
    $mtv2_qa = [ '10.252.73.0/24' ] # *.qa.mtv2.mozilla.com
}
