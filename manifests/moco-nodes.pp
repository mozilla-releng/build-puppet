# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Linux on moonshot in mdc1 running generic worker
# ms == moonshot == https://www.hpe.com/emea_europe/en/servers/moonshot.html
# xe == xen virtual machines on moonshot
# Workers range in MDC1:
# t-linux64-ms-001 - 015 - 15 workers
# t-linux64-ms-046 - 060 - 15 workers
# t-linux64-ms-091 - 105 - 15 workers
# t-linux64-ms-136 - 150 - 15 workers
# t-linux64-ms-181 - 195 - 15 workers
# t-linux64-ms-226 - 239 - 14 workers
# t-linux64-ms-271 - 279 - 9 workers
# TOTAL workers in MDC1 = 98 workers
#
# Workers range in MDC2:
# t-linux64-ms-301 - 315 - 15 workers
# t-linux64-ms-346 - 360 - 15 workers
# t-linux64-ms-391 - 405 - 15 workers
# t-linux64-ms-436 - 450 - 15 workers
# t-linux64-ms-481 - 495 - 15 workers
# t-linux64-ms-526 - 540 - 15 workers
# TOTAL workers in MDC2 = 90 workers
# TOTAL workers in gecko-t-linux-talos queue (MDC1+MDC2) = 188 workers

node /^t-linux64-(ms|xe)-\d{3}\.test\.releng\.(mdc1|mdc2)\.mozilla\.com$/ {
    $aspects          = [ 'low-security' ]
    $slave_trustlevel = 'try'
    $worker_type  = 'gecko-t-linux-talos'
    include fw::profiles::linux_taskcluster_worker
    include toplevel::worker::releng::generic_worker::test::gpu
}

## puppetmasters

node /^releng-puppet\d+\.srv\.releng\.(mdc1|mdc2)\.mozilla\.com$/ {
    $aspects       = [ 'maximum-security' ]
    $only_user_ssh = true
    include fw::profiles::puppetmasters
    include toplevel::server::puppetmaster
}

node 'releng-puppet2.srv.releng.mdc1.mozilla.com' {
    $aspects       = [ 'maximum-security' ]
    $only_user_ssh = true
    include fw::profiles::distinguished_puppetmaster
    include toplevel::server::puppetmaster
    class {
        'bacula_client':
            cert => secret('releng_puppet2_srv_releng_mdc1_bacula_cert'),
            key  => secret('releng_puppet2_srv_releng_mdc1_bacula_key');
    }
}

## deploystudio servers

node 'install.test.releng.mdc1.mozilla.com' {
    $aspects = [ 'maximum-security' ]
    include fw::profiles::deploystudio
    include toplevel::server::deploystudio
    class {
        'bacula_client':
            cert => secret('install_test_releng_mdc1_bacula_cert'),
            key  => secret('install_test_releng_mdc1_bacula_key');
    }
}

node 'install2.test.releng.mdc1.mozilla.com' {
    $aspects = [ 'maximum-security' ]
    include fw::profiles::deploystudio
    include toplevel::server::deploystudio
}

node 'install.test.releng.mdc2.mozilla.com' {
    $aspects = [ 'maximum-security' ]
    include fw::profiles::deploystudio
    include toplevel::server::deploystudio
    class {
        'bacula_client':
            cert => secret('install_test_releng_mdc2_bacula_cert'),
            key  => secret('install_test_releng_mdc2_bacula_key');
    }
}

node 'install2.test.releng.mdc2.mozilla.com' {
    $aspects = [ 'maximum-security' ]
    include fw::profiles::deploystudio
    include toplevel::server::deploystudio
}

## BSDPy hosts

node /^bsdpy\d+\.(test|tier3)\.releng\.(mdc1|mdc2)\.mozilla\.com$/ {
    # Same security level as Deploystudio
    $aspects       = [ 'maximum-security', 'prod' ]
    include fw::profiles::bsdpy
    include toplevel::server::bsdpy
}

## Jump hosts

node /^rejh\d+\.srv\.releng\.(mdc1|mdc2)\.mozilla\.com$/ {
    # jump host servers
    $aspects       = [ 'maximum-security' ]
    $timezone      = 'GMT'
    $only_user_ssh = true
    $duo_enabled   = true
    include fw::profiles::rejh
    include toplevel::jumphost
}

## Misc servers

node /^partner-repack-\d+\.srv\.releng\.(mdc1|mdc2)\.mozilla\.com$/ {
    $aspects       = [ 'maximum-security' ]
    $only_user_ssh = true
    include fw::profiles::partner_repack
    include toplevel::server
}

# Relops Controller

node /^roller1\.srv\.releng\.(mdc1|mdc2)\.mozilla\.com$/ {
    $aspects = [ 'high-security', 'prod' ]
    include fw::profiles::roller
    include toplevel::server::roller
}

node /^roller-dev1\.srv\.releng\.(mdc1|mdc2)\.mozilla\.com$/ {
    $aspects = [ 'high-security', 'dev' ]
    realize(Users::Person['gguthe'])
    include fw::profiles::roller
    include toplevel::server::roller
}

## Log Aggregators

node /^log-aggregator\d+\.srv\.releng\.(mdc1|mdc2)\.mozilla\.com$/ {
    $aspects                = [ 'high-security' ]
    $is_log_aggregator_host = 'true'
    include fw::profiles::log_aggregator
    include toplevel::server::log_aggregator
}

# Workers in linux talos staging pool
node 't-linux64-ms-280.test.releng.mdc1.mozilla.com',
    't-linux64-ms-240.test.releng.mdc1.mozilla.com',
    't-linux64-ms-394.test.releng.mdc2.mozilla.com',
    't-linux64-ms-395.test.releng.mdc2.mozilla.com' {
    $aspects          = [ 'low-security', 'staging' ]
    $slave_trustlevel = 'try'
    # We are limited to 22 characters for worker_type
    $worker_type = 'gecko-t-linux-talos-b'
    include fw::profiles::osx_taskcluster_worker
    include toplevel::worker::releng::generic_worker::test::gpu
}

