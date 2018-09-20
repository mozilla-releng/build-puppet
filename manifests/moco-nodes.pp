# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

## TaskCluster workers

# OS X in mdc1 running generic worker
node /^t-yosemite-r7-\d+\.test\.releng\.(mdc1|mdc2)\.mozilla\.com$/ {
    $aspects          = [ 'low-security' ]
    $slave_trustlevel = 'try'
    include fw::profiles::osx_taskcluster_worker
    include toplevel::worker::releng::generic_worker::test::gpu
}

# Linux on moonshot in mdc1 running taskcluster worker
node /^t-linux64-(ms|xe)-\d{3}\.test\.releng\.mdc1\.mozilla\.com$/ {
    $aspects          = [ 'low-security' ]
    $slave_trustlevel = 'try'
    $taskcluster_worker_type  = 'gecko-t-linux-talos-tw'
    include fw::profiles::linux_taskcluster_worker
    include toplevel::worker::releng::taskcluster_worker::test::gpu
}

# Linux on moonshot in mdc2 running taskcluster-worker, but will be migrated to generic-worker once bug 1474570 lands
# The migration is underway such that all taskcluster-worker workload is being moved from worker type
# gecko-t-linux-talos to gecko-t-linux-talos-tw, and that when that completes, gecko-t-linux-talos will then be used
# for generic-worker implementation of talos linux tasks. For more details, please see:
# https://bugzilla.mozilla.org/show_bug.cgi?id=1474570#c32

node /^t-linux64-(ms|xe)-\d{3}\.test\.releng\.mdc2\.mozilla\.com$/ {
    $aspects          = [ 'low-security' ]
    $slave_trustlevel = 'try'
    $taskcluster_worker_type  = 'gecko-t-linux-talos'
    include fw::profiles::linux_taskcluster_worker
    include toplevel::worker::releng::taskcluster_worker::test::gpu
}

# taskcluster-host-secrets hosts
node /^tc-host-secrets\d+\.srv\.releng\.(mdc1|mdc2)\.mozilla\.com$/ {
    $aspects                       = [ 'high-security' ]
    $taskcluster_host_secrets_port = 80
    include fw::profiles::taskcluster_host_secrets
    include toplevel::server::taskcluster_host_secrets
}

## signing servers

node /^mac-(v2-|)signing\d+\.srv\.releng\.(mdc1|mdc2)\.mozilla\.com$/ {
    # mac signing servers
    $aspects       = [ 'maximum-security' ]
    $timezone      = 'GMT'
    $only_user_ssh = true
    include fw::profiles::mac_signing
    include toplevel::server::signing
}

node /^signing\d+\.srv\.releng\.(mdc1|mdc2)\.mozilla\.com$/ {
    # linux signing servers
    $aspects       = [ 'maximum-security' ]
    $timezone      = 'UTC'
    $only_user_ssh = true
    include fw::profiles::signing
    include toplevel::server::signing
}

node /^mac-depsigning\d+\.srv\.releng\.(mdc1|mdc2)\.mozilla\.com$/ {
    # mac signing servers
    $aspects       = [ 'maximum-security' ]
    $timezone      = 'GMT'
    $only_user_ssh = true
    include fw::profiles::mac_depsigning
    include toplevel::server::depsigning
}

node /^depsigning\d+\.srv\.releng\.(mdc1|mdc2|use1|usw2)\.mozilla\.com$/ {
    # linux dev signing servers
    $aspects       = [ 'maximum-security' ]
    $timezone      = 'UTC'
    $only_user_ssh = true
    include toplevel::server::depsigning
}

## puppetmasters

node /^releng-puppet\d+\.srv\.releng\.(mdc1|mdc2|use1|usw2)\.mozilla\.com$/ {
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

node /^bsdpy\d+\.test\.releng\.(mdc1|mdc2)\.mozilla\.com$/ {
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

node /^dev-linux64-ec2-001.dev.releng.use1.mozilla.com$/ {
    # any dev or try node in the dev or try zones of use1 and usw2
    # dev-* hosts are *always* staging
    $aspects          = [ 'low-security' ]
    $slave_trustlevel = 'try'
    include toplevel::slave::releng::build::mock
    users::root::extra_authorized_key {
        'sledru': ;
    }
}

node /^cruncher-aws\.srv\.releng\.(use1|usw2)\.mozilla\.com$/ {
    $aspects = [ 'high-security' ]
    include toplevel::server::cruncher
}

node /^partner-repack-\d+\.srv\.releng\.(mdc1|mdc2)\.mozilla\.com$/ {
    $aspects       = [ 'maximum-security' ]
    $only_user_ssh = true
    include fw::profiles::partner_repack
    include toplevel::server
}

# buildduty-tools

node /^buildduty-tools\.srv\.releng\.(use1|usw2)\.mozilla\.com$/ {
    $aspects = [ 'medium-security' ]
    include toplevel::server::buildduty_tools
}

# mergeday

node /^mergeday\d+\.srv\.releng\.(use1|usw2)\.mozilla\.com$/ {
    $aspects = [ 'high-security' ]
    include toplevel::server::mergeday
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

# Package Builders

node /.*packager\d+\.srv\.releng\.use1\.mozilla\.com$/ {
    # RPM and DPKG package servers
    $aspects = [ 'low-security' ]
    include toplevel::server::pkgbuilder
}

## buildbot masters

node 'dev-master2.bb.releng.use1.mozilla.com' {
    $aspects       = [ 'high-security' ]
    $only_user_ssh = true
    include toplevel::server::buildmaster::mozilla

    # Bug 975004 - Grant pkewisch access to dev-master1
    # Bug 1265758 - Add acccess to the following accounts to dev-master2
    realize(Users::Person['sledru'])
    users::builder::extra_authorized_key {
        'sledru': ;
    }
}

node 'buildbot-master01.bb.releng.use1.mozilla.com' {
    $aspects       = [ 'high-security' ]
    $only_user_ssh = true
    $releaserunner3_env = 'prod'
    buildmaster::buildbot_master::mozilla {
        'bm01-tests1-linux32':
            http_port   => 8201,
            master_type => 'tests',
            basedir     => 'tests1-linux32';
    }
    $l10n_bumper_env = 'mozilla-beta'
    include toplevel::server::buildmaster::mozilla
    include toplevel::mixin::l10n_bumper
    include toplevel::mixin::releaserunner3
    include toplevel::mixin::bouncer_check
    include toplevel::mixin::signing_server_cert_check
}

node 'buildbot-master02.bb.releng.use1.mozilla.com' {
    $aspects       = [ 'high-security' ]
    $only_user_ssh = true
    buildmaster::buildbot_master::mozilla {
        'bm02-tests1-linux32':
            http_port   => 8201,
            master_type => 'tests',
            basedir     => 'tests1-linux32';
    }
    include toplevel::server::buildmaster::mozilla
}

node 'buildbot-master04.bb.releng.usw2.mozilla.com' {
    $aspects       = [ 'high-security' ]
    $only_user_ssh = true
    buildmaster::buildbot_master::mozilla {
        'bm04-tests1-linux32':
            http_port   => 8201,
            master_type => 'tests',
            basedir     => 'tests1-linux32';
    }
    include toplevel::server::buildmaster::mozilla
}

node 'buildbot-master05.bb.releng.usw2.mozilla.com' {
    $aspects       = [ 'high-security' ]
    $only_user_ssh = true
    buildmaster::buildbot_master::mozilla {
        'bm05-tests1-linux32':
            http_port   => 8201,
            master_type => 'tests',
            basedir     => 'tests1-linux32';
    }
    include toplevel::server::buildmaster::mozilla
}

node 'buildbot-master51.bb.releng.use1.mozilla.com' {
    $aspects       = [ 'high-security' ]
    $only_user_ssh = true
    buildmaster::buildbot_master::mozilla {
        'bm51-tests1-linux64':
            http_port   => 8201,
            master_type => 'tests',
            basedir     => 'tests1-linux64';
    }
    include toplevel::server::buildmaster::mozilla
}

node 'buildbot-master52.bb.releng.use1.mozilla.com' {
    $aspects       = [ 'high-security' ]
    $only_user_ssh = true
    buildmaster::buildbot_master::mozilla {
        'bm52-tests1-linux64':
            http_port   => 8201,
            master_type => 'tests',
            basedir     => 'tests1-linux64';
    }
    include toplevel::server::buildmaster::mozilla
}

node 'buildbot-master53.bb.releng.usw2.mozilla.com' {
    $aspects       = [ 'high-security' ]
    $only_user_ssh = true
    buildmaster::buildbot_master::mozilla {
        'bm53-tests1-linux64':
            http_port   => 8201,
            master_type => 'tests',
            basedir     => 'tests1-linux64';
    }
    include toplevel::server::buildmaster::mozilla
}

node 'buildbot-master54.bb.releng.usw2.mozilla.com' {
    $aspects       = [ 'high-security' ]
    $only_user_ssh = true
    buildmaster::buildbot_master::mozilla {
        'bm54-tests1-linux64':
            http_port   => 8201,
            master_type => 'tests',
            basedir     => 'tests1-linux64';
    }
    include toplevel::server::buildmaster::mozilla
}

node 'buildbot-master69.bb.releng.use1.mozilla.com' {
    $aspects       = [ 'high-security' ]
    $only_user_ssh = true
    buildmaster::buildbot_master::mozilla {
        'bm69-tests1-windows':
            http_port   => 8201,
            master_type => 'tests',
            basedir     => 'tests1-windows';
    }
    include toplevel::server::buildmaster::mozilla
}

node 'buildbot-master71.bb.releng.use1.mozilla.com' {
    $aspects       = [ 'high-security' ]
    $only_user_ssh = true
    buildmaster::buildbot_master::mozilla {
        'bm71-build1':
            http_port   => 8001,
            master_type => 'build',
            basedir     => 'build1';
    }
    include toplevel::server::buildmaster::mozilla
    include toplevel::mixin::selfserve_agent
}

node 'buildbot-master72.bb.releng.usw2.mozilla.com' {
    $aspects              = [ 'high-security' ]
    $only_user_ssh        = true
    $buildbot_bridge_env  = 'prod'
    $buildbot_bridge2_env = 'prod'
    buildmaster::buildbot_master::mozilla {
        'bm72-build1':
            http_port   => 8001,
            master_type => 'build',
            basedir     => 'build1';
    }
    include toplevel::server::buildmaster::mozilla
    include toplevel::mixin::selfserve_agent
    include toplevel::mixin::buildbot_bridge
    include toplevel::mixin::buildbot_bridge2
}

node 'buildbot-master73.bb.releng.usw2.mozilla.com' {
    $aspects       = [ 'high-security' ]
    $only_user_ssh = true
    buildmaster::buildbot_master::mozilla {
        'bm73-build1':
            http_port   => 8001,
            master_type => 'build',
            basedir     => 'build1';
    }
    include toplevel::server::buildmaster::mozilla
    include toplevel::mixin::selfserve_agent
}

node 'buildbot-master75.bb.releng.use1.mozilla.com' {
    $aspects       = [ 'high-security' ]
    $only_user_ssh = true
    buildmaster::buildbot_master::mozilla {
        'bm75-try1':
            http_port   => 8101,
            master_type => 'try',
            basedir     => 'try1';
    }
    include toplevel::server::buildmaster::mozilla
}

node 'buildbot-master77.bb.releng.use1.mozilla.com' {
    $aspects         = [ 'high-security' ]
    $only_user_ssh   = true
    $releaserunner3_env = 'dev'
    buildmaster::buildbot_master::mozilla {
        'bm77-build1':
            http_port   => 8001,
            master_type => 'build',
            basedir     => 'build1';
    }
    $l10n_bumper_env = 'mozilla-central'
    include toplevel::server::buildmaster::mozilla
    include toplevel::mixin::l10n_bumper
    include toplevel::mixin::releaserunner3
    include toplevel::mixin::signing_server_cert_check
}

node 'buildbot-master78.bb.releng.usw2.mozilla.com' {
    $aspects       = [ 'high-security' ]
    $only_user_ssh = true
    buildmaster::buildbot_master::mozilla {
        'bm78-try1':
            http_port   => 8101,
            master_type => 'try',
            basedir     => 'try1';
    }
    include toplevel::server::buildmaster::mozilla
}

node 'buildbot-master128.bb.releng.use1.mozilla.com' {
    $aspects       = [ 'high-security' ]
    $only_user_ssh = true
    buildmaster::buildbot_master::mozilla {
        'bm128-tests1-windows':
            http_port   => 8201,
            master_type => 'tests',
            basedir     => 'tests1-windows';
    }
    include toplevel::server::buildmaster::mozilla
}

node 'buildbot-master137.bb.releng.use1.mozilla.com' {
    $aspects       = [ 'high-security' ]
    $only_user_ssh = true
    buildmaster::buildbot_master::mozilla {
        'bm137-tests1-windows':
            http_port   => 8201,
            master_type => 'tests',
            basedir     => 'tests1-windows';
    }
    include toplevel::server::buildmaster::mozilla
}

node 'buildbot-master138.bb.releng.use1.mozilla.com' {
    $aspects       = [ 'high-security' ]
    $only_user_ssh = true
    buildmaster::buildbot_master::mozilla {
        'bm138-tests1-windows':
            http_port   => 8201,
            master_type => 'tests',
            basedir     => 'tests1-windows';
    }
    include toplevel::server::buildmaster::mozilla
}

node 'buildbot-master139.bb.releng.usw2.mozilla.com' {
    $aspects       = [ 'high-security' ]
    $only_user_ssh = true
    buildmaster::buildbot_master::mozilla {
        'bm139-tests1-windows':
            http_port   => 8201,
            master_type => 'tests',
            basedir     => 'tests1-windows';
    }
    include toplevel::server::buildmaster::mozilla
}

node 'buildbot-master140.bb.releng.usw2.mozilla.com' {
    $aspects       = [ 'high-security' ]
    $only_user_ssh = true
    buildmaster::buildbot_master::mozilla {
        'bm140-tests1-windows':
            http_port   => 8201,
            master_type => 'tests',
            basedir     => 'tests1-windows';
    }
    include toplevel::server::buildmaster::mozilla
}

node /^log-aggregator\d+\.srv\.releng\.(mdc1|mdc2|use1|usw2)\.mozilla\.com$/ {
    $aspects                = [ 'high-security' ]
    $is_log_aggregator_host = 'true'
    include fw::profiles::log_aggregator
    include toplevel::server::log_aggregator
}

# Signing workers
node /^signingworker-.*\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects       = [ 'maximum-security' ]
    $only_user_ssh = true
    include toplevel::server::signingworker
}

# Signing scriptworkers
node /^signing-linux-\d*\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects                  = [ 'maximum-security' ]
    $signing_scriptworker_env = 'prod'
    $timezone                 = 'UTC'
    $only_user_ssh            = true
    include toplevel::server::signingscriptworker
}

node /^depsigning-worker.*\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects                  = [ 'maximum-security' ]
    $signing_scriptworker_env = 'dep'
    $timezone                 = 'UTC'
    $only_user_ssh            = true
    include toplevel::server::signingscriptworker
}

node /^signing-linux-dev.*\.releng\..*\.mozilla\.com$/ {
    $aspects                  = [ 'maximum-security' ]
    $signing_scriptworker_env = 'dev'
    $timezone                 = 'UTC'
    $only_user_ssh            = true
    include toplevel::server::signingscriptworker
}

node /^tb-signing-\d*\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects                  = [ 'maximum-security' ]
    $signing_scriptworker_env = 'comm-thunderbird-prod'
    $timezone                 = 'UTC'
    $only_user_ssh            = true
    include toplevel::server::signingscriptworker
}

node /^tb-depsigning-worker.*\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects                  = [ 'maximum-security' ]
    $signing_scriptworker_env = 'comm-thunderbird-dep'
    $timezone                 = 'UTC'
    $only_user_ssh            = true
    include toplevel::server::signingscriptworker
}

# https://github.com/mozilla-mobile workers. The "e" in mobile was stripped out
# in order to leave up to 100 workers instead of 10.
node /^mobil-signing-linux-\d*\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects                  = [ 'maximum-security' ]
    $signing_scriptworker_env = 'mobile-prod'
    $timezone                 = 'UTC'
    $only_user_ssh            = true
    include toplevel::server::signingscriptworker
}

# Addon scriptworkers
node /^addonworker-\d*\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects          = [ 'maximum-security' ]
    $addon_scriptworker_env = 'prod'
    $timezone         = 'UTC'
    $only_user_ssh    = true
    include toplevel::server::addonscriptworker
}

node /^addonworker-dev-\d*\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects          = [ 'maximum-security' ]
    $addon_scriptworker_env = 'dev'
    $timezone         = 'UTC'
    $only_user_ssh    = true
    include toplevel::server::addonscriptworker
}

# Balrog scriptworkers
node /^balrogworker-\d*\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects          = [ 'maximum-security' ]
    $balrogworker_env = 'prod'
    $timezone         = 'UTC'
    $only_user_ssh    = true
    include toplevel::server::balrogscriptworker
}

node /^balrogworker-dev\d*\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects          = [ 'maximum-security' ]
    $balrogworker_env = 'dev'
    $timezone         = 'UTC'
    $only_user_ssh    = true
    include toplevel::server::balrogscriptworker
}

node /^tb-balrog-\d+\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects          = [ 'maximum-security' ]
    $balrogworker_env = 'comm-thunderbird-prod'
    $timezone         = 'UTC'
    $only_user_ssh    = true
    include toplevel::server::balrogscriptworker
}

node /^tb-balrogworker-dev\d+\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects          = [ 'maximum-security' ]
    $balrogworker_env = 'comm-thunderbird-dev'
    $timezone         = 'UTC'
    $only_user_ssh    = true
    include toplevel::server::balrogscriptworker
}

# Beetmover scriptworkers
node /^beetmoverworker-.*\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects             = [ 'maximum-security' ]
    $beetmoverworker_env = 'prod'
    $timezone            = 'UTC'
    $only_user_ssh       = true
    include toplevel::server::beetmoverscriptworker
}

node /^beetmover-dev.*\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects             = [ 'maximum-security' ]
    $beetmoverworker_env = 'dev'
    $timezone            = 'UTC'
    $only_user_ssh       = true
    include toplevel::server::beetmoverscriptworker
}

node /^tb-beetmover-\d+\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects             = [ 'maximum-security' ]
    $beetmoverworker_env = 'comm-thunderbird-prod'
    $timezone            = 'UTC'
    $only_user_ssh       = true
    include toplevel::server::beetmoverscriptworker
}

node /^tb-beetmover-dev\d+\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects             = [ 'maximum-security' ]
    $beetmoverworker_env = 'comm-thunderbird-dev'
    $timezone            = 'UTC'
    $only_user_ssh       = true
    include toplevel::server::beetmoverscriptworker
}

# https://github.com/mozilla-mobile workers.
node /^mobile-beetmover-\d*\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects                  = [ 'maximum-security' ]
    $beetmoverworker_env = 'mobile-staging'
    $timezone                 = 'UTC'
    $only_user_ssh            = true
    include toplevel::server::beetmoverscriptworker
}

# Bouncer scriptworkers
node /^bouncerworker-dev.*\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects                  = [ 'maximum-security' ]
    $bouncer_scriptworker_env = 'dev'
    $timezone                 = 'UTC'
    $only_user_ssh            = true
    include toplevel::server::bouncerscriptworker
}

node /^bouncerworker-.*\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects                  = [ 'maximum-security' ]
    $bouncer_scriptworker_env = 'prod'
    $timezone                 = 'UTC'
    $only_user_ssh            = true
    include toplevel::server::bouncerscriptworker
}

node /^tb-bouncer-dev-\d+\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects                  = [ 'maximum-security' ]
    $bouncer_scriptworker_env = 'comm-thunderbird-dev'
    $timezone                 = 'UTC'
    $only_user_ssh            = true
    include toplevel::server::bouncerscriptworker
}

node /^tb-bouncer-\d+\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects                  = [ 'maximum-security' ]
    $bouncer_scriptworker_env = 'comm-thunderbird-prod'
    $timezone                 = 'UTC'
    $only_user_ssh            = true
    include toplevel::server::bouncerscriptworker
}

# PushAPK scriptworkers
node /^dep-pushapkworker-.*\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects                  = [ 'maximum-security' ]
    $pushapk_scriptworker_env = 'dep'
    $timezone                 = 'UTC'
    $only_user_ssh            = true
    include toplevel::server::pushapkscriptworker
}

node /^pushapkworker-.*\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects                  = [ 'maximum-security' ]
    $pushapk_scriptworker_env = 'prod'
    $timezone                 = 'UTC'
    $only_user_ssh            = true
    include toplevel::server::pushapkscriptworker
}

# https://github.com/mozilla-mobile workers. The "e" in mobile was stripped out
# in order to leave up to 100 workers instead of 10.
node /^mobil-pushapkworker-\d*\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects                  = [ 'maximum-security' ]
    $pushapk_scriptworker_env = 'mobile-prod'
    $timezone                 = 'UTC'
    $only_user_ssh            = true
    include toplevel::server::pushapkscriptworker
}

# PushSnap scriptworkers
node /^dep-pushsnapworker-.*\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects                  = [ 'maximum-security' ]
    $pushsnap_scriptworker_env = 'dep'
    $timezone                 = 'UTC'
    $only_user_ssh            = true
    include toplevel::server::pushsnapscriptworker
}

node /^pushsnapworker-.*\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects                  = [ 'maximum-security' ]
    $pushsnap_scriptworker_env = 'prod'
    $timezone                 = 'UTC'
    $only_user_ssh            = true
    include toplevel::server::pushsnapscriptworker
}


# Transparency scriptworkers
node /^binarytransparencyworker-.*\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects = [ 'maximum-security' ]
    $transparencyworker_env = "dev"
    $timezone = "UTC"
    $only_user_ssh = true
    include toplevel::server::transparencyscriptworker
}

# shipit scriptworkers
node /^shipitworker-dev-.*\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects                  = [ 'maximum-security' ]
    $shipit_scriptworker_env  = 'dev'
    $timezone                 = 'UTC'
    $only_user_ssh            = true
    include toplevel::server::shipitscriptworker
}

node /^shipitworker-.*\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects                  = [ 'maximum-security' ]
    $shipit_scriptworker_env  = 'prod'
    $timezone                 = 'UTC'
    $only_user_ssh            = true
    include toplevel::server::shipitscriptworker
}

node /^tb-shipit-dev-\d+\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects                  = [ 'maximum-security' ]
    $shipit_scriptworker_env  = 'tb-dev'
    $timezone                 = 'UTC'
    $only_user_ssh            = true
    include toplevel::server::shipitscriptworker
}

node /^tb-shipit-\d+\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects                  = [ 'maximum-security' ]
    $shipit_scriptworker_env  = 'tb-prod'
    $timezone                 = 'UTC'
    $only_user_ssh            = true
    include toplevel::server::shipitscriptworker
}

# Treescript workers
node /^treescriptworker-dev\d*\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects          = [ 'maximum-security' ]
    $treescriptworker_env = 'dev'
    $timezone         = 'UTC'
    $only_user_ssh    = true
    include toplevel::server::treescriptworker
}

node /^treescriptworker\d*\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects          = [ 'maximum-security' ]
    $treescriptworker_env = 'prod'
    $timezone         = 'UTC'
    $only_user_ssh    = true
    include toplevel::server::treescriptworker
}

node /^tb-tree-comm-dev-\d+\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects          = [ 'maximum-security' ]
    $treescriptworker_env = 'tb-comm-dev'
    $timezone         = 'UTC'
    $only_user_ssh    = true
    include toplevel::server::treescriptworker
}

node /^tb-tree-comm-\d+\.srv\.releng\..*\.mozilla\.com$/ {
    $aspects          = [ 'maximum-security' ]
    $treescriptworker_env = 'tb-comm-prod'
    $timezone         = 'UTC'
    $only_user_ssh    = true
    include toplevel::server::treescriptworker
}

## Loaners

# Loaner for testing security patches
# See Bug 1433165 and Bug 1385050
node 'relops-patching1.srv.releng.mdc1.mozilla.com' {
    $aspects = [ 'low-security' ]
    $pin_puppet_server = 'releng-puppet2.srv.releng.scl3.mozilla.com'
    $pin_puppet_env    = 'dcrisan'
    include toplevel::server
}

# Loaner for dividehex; bug 1445842 and 1447766
node 'ds-test1.srv.releng.mdc2.mozilla.com' {
    $aspects = [ 'low-security' ]
    include toplevel::server
}

# Workers in osx staging pool
node 't-yosemite-r7-380.test.releng.mdc1.mozilla.com',
    't-yosemite-r7-394.test.releng.mdc1.mozilla.com',
    't-yosemite-r7-100.test.releng.mdc2.mozilla.com',
    't-yosemite-r7-101.test.releng.mdc2.mozilla.com' {
    $aspects          = [ 'low-security', 'staging' ]
    $slave_trustlevel = 'try'
    include fw::profiles::osx_taskcluster_worker
    include toplevel::worker::releng::generic_worker::test::gpu
}


# Workers in linux talos staging pool
node 't-linux64-ms-280.test.releng.mdc1.mozilla.com',
    't-linux64-ms-240.test.releng.mdc1.mozilla.com',
    't-linux64-ms-394.test.releng.mdc2.mozilla.com',
    't-linux64-ms-395.test.releng.mdc2.mozilla.com' {
    $aspects          = [ 'low-security', 'staging' ]
    $slave_trustlevel = 'try'
    include fw::profiles::osx_taskcluster_worker
    include toplevel::worker::releng::generic_worker::test::gpu
}
