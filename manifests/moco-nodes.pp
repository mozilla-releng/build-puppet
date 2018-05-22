# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

## Buildbot OS X
# 19 machines that will remain in buildbot
node /^t-yosemite-r7-00[0-1]\d+\.test\.releng\.scl3\.mozilla\.com$/ {
    $aspects          = [ 'low-security' ]
    $slave_trustlevel = 'try'
    include fw::profiles::buildbot_slave
    include toplevel::slave::releng::test::gpu
}
## TaskCluster workers

# OS X in mdc1 running generic worker
node /^t-yosemite-r7-\d+\.test\.releng\.(mdc1|mdc2|scl3)\.mozilla\.com$/ {
    $aspects          = [ 'low-security' ]
    $slave_trustlevel = 'try'
    include fw::profiles::osx_taskcluster_worker
    include toplevel::worker::releng::generic_worker::test::gpu
}

# Linux on moonshot in mdc1 running taskcluster worker
node /^t-linux64-(ms|xe)-\d{3}\.test\.releng\.(mdc1|mdc2)\.mozilla\.com$/ {
    $aspects          = [ 'low-security' ]
    $slave_trustlevel = 'try'
    $taskcluster_worker_type  = 'gecko-t-linux-talos'
    include fw::profiles::linux_taskcluster_worker
    include toplevel::worker::releng::taskcluster_worker::test::gpu
}


# taskcluster-host-secrets hosts
node /^tc-host-secrets\d+\.srv\.releng\.(mdc1|mdc2|scl3)\.mozilla\.com$/ {
    $aspects                       = [ 'high-security' ]
    $taskcluster_host_secrets_port = 80
    include fw::profiles::taskcluster_host_secrets
    include toplevel::server::taskcluster_host_secrets
}


## Buildbot testers

# Linux and OS X
node /^t.*-\d+\.test\.releng\.scl3\.mozilla\.com$/ {
    # hosts starting with t and ending in -digit.test.releng.scl3.mozilla.com
    $aspects          = [ 'low-security' ]
    $slave_trustlevel = 'try'
    include fw::profiles::buildbot_slave
    include toplevel::slave::releng::test::gpu
}

# AWS
node /^tst-.*\.test\.releng\.(use1|usw2)\.mozilla\.com$/ {
    # tst-anything in any region of the test.releng mozilla zones
    $aspects          = [ 'low-security' ]
    $slave_trustlevel = 'try'
    include toplevel::slave::releng::test::headless
}

# Windows
node /^t-w732.*\.(wintest|test)\.releng\.(scl3|use1|usw2)\.mozilla.com$/ {
    # windows 7 nodes in wintest.releng.scl3.mozilla.com
    $aspects          = [ 'low-security' ]
    $slave_trustlevel = 'try'
    include toplevel::slave
}
node /^g-w732.*\.(wintest|test)\.releng\.(scl3|use1|usw2)\.mozilla.com$/ {
    # windows 7 nodes in wintest.releng.scl3.mozilla.com
    $aspects          = [ 'low-security' ]
    $slave_trustlevel = 'try'
    include toplevel::slave
}

# Node declaration is for Win 7 development
# To keep development and production catalogs separate
node /^d-w732.*\.(wintest|test)\.releng\.(scl3|use1|usw2)\.mozilla.com$/ {
    # windows 7 nodes in wintest.releng.scl3.mozilla.com
    $aspects          = [ 'low-security' ]
    $slave_trustlevel = 'try'
    include toplevel::slave::releng::test
}

## Buildbot builders

# Windows
node /^b-2008.*\.(winbuild|build)\.releng\.(scl3|use1|usw2)\.mozilla.com$/ {
    $aspects          = [ 'low-security' ]
    $slave_trustlevel = 'core'
    include toplevel::slave::releng::build
}

# linux64
node /^b-linux64-\w+-\d+.build.releng.scl3.mozilla.com$/ {
    # any b-linux64-(something)-digit host in the scl3 build zone
    $aspects          = [ 'low-security' ]
    $slave_trustlevel = 'core'
    include toplevel::slave::releng::build::mock
}

node /^bld-.*\.build\.releng\.(use1|usw2)\.mozilla.com$/ {
    # any bld-(something) host in the use1 and usw2 releng build zones
    $aspects          = [ 'low-security' ]
    $slave_trustlevel = 'core'
    include toplevel::slave::releng::build::mock
}

node /^av-linux64.*\.build\.releng\.(use1|usw2)\.mozilla\.com$/ {
    $aspects          = [ 'low-security' ]
    $slave_trustlevel = 'core'
    include toplevel::slave::releng::build::mock::av
}

# OS X
node /^bld-lion-r5-\d+\.build\.releng\.scl3\.mozilla\.com$/ {
    # any bld-lion-r5-(digit) hosts in the scl3 build zone
    $slave_trustlevel = 'core'
    $aspects          = [ 'low-security' ]
    include fw::profiles::buildbot_slave
    include toplevel::slave::releng::build::standard
}

## Buildbot try builders

# Windows
node /^(b|y|try)-2008-.*\.(try|wintry).releng.(use1|usw2|scl3).mozilla.com$/ {
    $slave_trustlevel = 'try'
    $aspects          = [ 'low-security' ]
    include toplevel::slave::releng::build
}

# Datacenter Windows builder for testing
node 'ix-mn-w0864-002.wintest.releng.scl3.mozilla.com' {
    $aspects          = [ 'low-security' ]
    $slave_trustlevel = 'try'
    include toplevel::slave::releng::build
}

# linux64
node /^b-linux64-\w+-\d+.try.releng.scl3.mozilla.com$/ {
    # any b-linux64-(something)-digit host in the scl3 try zone
    $aspects          = [ 'low-security' ]
    $slave_trustlevel = 'try'
    include toplevel::slave::releng::build::mock
}

node /^(dev|try)-.*\.(dev|try)\.releng\.(use1|usw2)\.mozilla.com$/ {
    # any dev or try node in the dev or try zones of use1 and usw2
    # dev-* hosts are *always* staging
    $aspects          = [ 'low-security' ]
    $slave_trustlevel = 'try'
    include toplevel::slave::releng::build::mock
}

# OS X

node /^bld-(lion|yosemite)-r5-\d+.try.releng.scl3.mozilla.com$/ {
    $aspects          = [ 'low-security' ]
    $slave_trustlevel = 'try'
    include fw::profiles::buildbot_slave
    include toplevel::slave::releng::build::standard
}

node /^y-yosemite-r5-\d+.try.releng.scl3.mozilla.com$/ {
    $aspects          = [ 'low-security' ]
    $slave_trustlevel = 'try'
    include fw::profiles::buildbot_slave
    include toplevel::slave::releng::build::standard
}

## signing servers

node /^mac-(v2-|)signing\d+\.srv\.releng\.(mdc1|mdc2|scl3)\.mozilla\.com$/ {
    # mac signing servers
    $aspects       = [ 'maximum-security' ]
    $timezone      = 'GMT'
    $only_user_ssh = true
    include fw::profiles::mac_signing
    include toplevel::server::signing
}

node /^signing\d+\.srv\.releng\.(mdc1|mdc2|scl3)\.mozilla\.com$/ {
    # linux signing servers
    $aspects       = [ 'maximum-security' ]
    $timezone      = 'UTC'
    $only_user_ssh = true
    include fw::profiles::signing
    include toplevel::server::signing
}

node /^mac-depsigning\d+\.srv\.releng\.(mdc1|mdc2|scl3)\.mozilla\.com$/ {
    # mac signing servers
    $aspects       = [ 'maximum-security' ]
    $timezone      = 'GMT'
    $only_user_ssh = true
    include fw::profiles::mac_depsigning
    include toplevel::server::depsigning
}

node /^depsigning\d+\.srv\.releng\.(mdc1|mdc2|scl3|use1|usw2)\.mozilla\.com$/ {
    # linux dev signing servers
    $aspects       = [ 'maximum-security' ]
    $timezone      = 'UTC'
    $only_user_ssh = true
    include toplevel::server::depsigning
}

## puppetmasters

node /^releng-puppet\d+\.srv\.releng\.(mdc1|mdc2|scl3|use1|usw2)\.mozilla\.com$/ {
    $aspects       = [ 'maximum-security' ]
    $only_user_ssh = true
    include fw::profiles::puppetmasters
    include toplevel::server::puppetmaster
}

node 'releng-puppet2.srv.releng.scl3.mozilla.com' {
    $aspects       = [ 'maximum-security' ]
    $only_user_ssh = true
    include fw::profiles::distinguished_puppetmaster
    include toplevel::server::puppetmaster
    class {
        'bacula_client':
            cert => secret('releng_puppet2_srv_releng_scl3_bacula_cert'),
            key  => secret('releng_puppet2_srv_releng_scl3_bacula_key');
    }
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

node 'install.build.releng.scl3.mozilla.com' {
    $aspects = [ 'maximum-security' ]
    include fw::profiles::deploystudio
    include toplevel::server::deploystudio
    class {
        'bacula_client':
            cert => secret('install_build_releng_scl3_bacula_cert'),
            key  => secret('install_build_releng_scl3_bacula_key');
    }
}

node 'install.test.releng.scl3.mozilla.com' {
    $aspects = [ 'maximum-security' ]
    include toplevel::server::deploystudio
    include fw::profiles::deploystudio
    class {
        'bacula_client':
            cert => secret('install_test_releng_scl3_bacula_cert'),
            key  => secret('install_test_releng_scl3_bacula_key');
    }
}

node 'install3.test.releng.scl3.mozilla.com' {
    $aspects = [ 'maximum-security' ]
    include fw::profiles::deploystudio
    include toplevel::server::deploystudio
}

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

## Jump hosts

node /^rejh\d+\.srv\.releng\.(mdc1|mdc2|scl3)\.mozilla\.com$/ {
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

# aws-manager

node /^aws-manager\d+\.srv\.releng\.scl3\.mozilla\.com$/ {
    $aspects = [ 'high-security' ]
    include fw::profiles::aws_manager
    include toplevel::server::aws_manager
}

# buildduty-tools

node /^buildduty-tools\.srv\.releng\.(use1|usw2)\.mozilla\.com$/ {
    $aspects = [ 'medium-security' ]
    include toplevel::server::buildduty_tools
}

# slaveapi

node 'slaveapi1.srv.releng.scl3.mozilla.com' {
    $aspects = [ 'high-security' ]
    include fw::profiles::slave_api
    include toplevel::server::slaveapi
}

node 'slaveapi-dev1.srv.releng.scl3.mozilla.com' {
    $aspects = [ 'high-security', 'dev' ]
    include fw::profiles::slave_api
    include toplevel::server::slaveapi
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
    buildmaster::buildbot_master::mozilla {
        'bm01-tests1-linux32':
            http_port   => 8201,
            master_type => 'tests',
            basedir     => 'tests1-linux32';
    }
    $l10n_bumper_env = 'mozilla-beta'
    include toplevel::server::buildmaster::mozilla
    include toplevel::mixin::l10n_bumper
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
    buildmaster::buildbot_master::mozilla {
        'bm77-build1':
            http_port   => 8001,
            master_type => 'build',
            basedir     => 'build1';
    }
    $l10n_bumper_env = 'mozilla-central'
    include toplevel::server::buildmaster::mozilla
    include toplevel::mixin::l10n_bumper
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

node 'buildbot-master81.bb.releng.scl3.mozilla.com' {
    $aspects           = [ 'high-security' ]
    $only_user_ssh     = true
    $releaserunner_env = 'prod-old'
    # This runs the `old-release-runner` branch, but we can't set
    # `$releaserunner_tools_branch` because we don't want to tag that branch.
    buildmaster::buildbot_master::mozilla {
        'bm81-build_scheduler':
            master_type => 'scheduler',
            basedir     => 'build_scheduler';
        'bm81-tests_scheduler':
            master_type => 'scheduler',
            basedir     => 'tests_scheduler';
    }
    include fw::profiles::buildbot_master
    include toplevel::server::buildmaster::mozilla
    include toplevel::mixin::selfserve_agent
    include toplevel::mixin::releaserunner
    include toplevel::mixin::buildmaster_db_maintenance
    include toplevel::mixin::bouncer_check
}

node 'buildbot-master82.bb.releng.scl3.mozilla.com' {
    $aspects              = [ 'high-security' ]
    $only_user_ssh        = true
    $buildbot_bridge_env  = 'prod'
    $buildbot_bridge2_env = 'prod'
    buildmaster::buildbot_master::mozilla {
        'bm82-build1':
            http_port   => 8001,
            master_type => 'build',
            basedir     => 'build1';
    }
    include fw::profiles::buildbot_master
    include toplevel::server::buildmaster::mozilla
    include toplevel::mixin::buildbot_bridge
    include toplevel::mixin::buildbot_bridge2
}

node 'buildbot-master83.bb.releng.scl3.mozilla.com' {
    $aspects           = [ 'high-security' ]
    $only_user_ssh     = true
    $releaserunner_env = 'dev'
    $releaserunner3_env = 'dev'
    buildmaster::buildbot_master::mozilla {
        'bm83-try1':
            http_port   => 8101,
            master_type => 'try',
            basedir     => 'try1';
    }
    include fw::profiles::buildbot_master
    include toplevel::server::buildmaster::mozilla
    include toplevel::mixin::releaserunner
    include toplevel::mixin::releaserunner3
}

node 'buildbot-master84.bb.releng.scl3.mozilla.com' {
    $aspects              = [ 'high-security' ]
    $only_user_ssh        = true
    $buildbot_bridge_env  = 'dev'
    $buildbot_bridge2_env = 'dev'
    buildmaster::buildbot_master::mozilla {
        'bm84-build1':
            http_port   => 8001,
            master_type => 'build',
            basedir     => 'build1';
    }
    include fw::profiles::buildbot_master
    include toplevel::server::buildmaster::mozilla
    include toplevel::mixin::buildbot_bridge
    include toplevel::mixin::buildbot_bridge2
}

node 'buildbot-master85.bb.releng.scl3.mozilla.com' {
    $aspects           = [ 'high-security' ]
    $only_user_ssh     = true
    $releaserunner_env = 'prod'
    $releaserunner3_env = 'prod'
    buildmaster::buildbot_master::mozilla {
        'bm85-build1':
            http_port   => 8001,
            master_type => 'build',
            basedir     => 'build1';
    }
    include fw::profiles::buildbot_master
    include toplevel::server::buildmaster::mozilla
    include toplevel::mixin::releaserunner
    include toplevel::mixin::releaserunner3
}

node 'buildbot-master86.bb.releng.scl3.mozilla.com' {
    $aspects              = [ 'high-security' ]
    $only_user_ssh        = true
    $buildbot_bridge_env  = 'prod'
    $buildbot_bridge2_env = 'prod'
    buildmaster::buildbot_master::mozilla {
        'bm86-build1':
            http_port   => 8001,
            master_type => 'build',
            basedir     => 'build1';
    }
    include fw::profiles::buildbot_master
    include toplevel::server::buildmaster::mozilla
    include toplevel::mixin::buildbot_bridge
    include toplevel::mixin::buildbot_bridge2
}

node 'buildbot-master87.bb.releng.scl3.mozilla.com' {
    $aspects       = [ 'high-security' ]
    $only_user_ssh = true
    buildmaster::buildbot_master::mozilla {
        'bm87-try1':
            http_port   => 8101,
            master_type => 'try',
            basedir     => 'try1';
    }
    include fw::profiles::buildbot_master
    include toplevel::server::buildmaster::mozilla
}

node 'buildbot-master103.bb.releng.scl3.mozilla.com' {
    $aspects       = [ 'high-security' ]
    $only_user_ssh = true
    buildmaster::buildbot_master::mozilla {
        'bm103-tests1-linux':
            http_port   => 8201,
            master_type => 'tests',
            basedir     => 'tests1-linux';
    }
    include fw::profiles::buildbot_master
    include toplevel::server::buildmaster::mozilla
}

node 'buildbot-master104.bb.releng.scl3.mozilla.com' {
    $aspects       = [ 'high-security' ]
    $only_user_ssh = true
    buildmaster::buildbot_master::mozilla {
        'bm104-tests1-linux':
            http_port   => 8201,
            master_type => 'tests',
            basedir     => 'tests1-linux';
    }
    include fw::profiles::buildbot_master
    include toplevel::server::buildmaster::mozilla
}

node 'buildbot-master105.bb.releng.scl3.mozilla.com' {
    $aspects       = [ 'high-security' ]
    $only_user_ssh = true
    buildmaster::buildbot_master::mozilla {
        'bm105-tests1-linux':
            http_port   => 8201,
            master_type => 'tests',
            basedir     => 'tests1-linux';
    }
    include fw::profiles::buildbot_master
    include toplevel::server::buildmaster::mozilla
}

node 'buildbot-master106.bb.releng.scl3.mozilla.com' {
    $aspects       = [ 'high-security' ]
    $only_user_ssh = true
    buildmaster::buildbot_master::mozilla {
        'bm106-tests1-macosx':
            http_port   => 8201,
            master_type => 'tests',
            basedir     => 'tests1-macosx';
    }
    include fw::profiles::buildbot_master
    include toplevel::server::buildmaster::mozilla
}

node 'buildbot-master107.bb.releng.scl3.mozilla.com' {
    $aspects       = [ 'high-security' ]
    $only_user_ssh = true
    buildmaster::buildbot_master::mozilla {
        'bm107-tests1-macosx':
            http_port   => 8201,
            master_type => 'tests',
            basedir     => 'tests1-macosx';
    }
    include fw::profiles::buildbot_master
    include toplevel::server::buildmaster::mozilla
}


node 'buildbot-master109.bb.releng.scl3.mozilla.com' {
    $aspects       = [ 'high-security' ]
    $only_user_ssh = true
    buildmaster::buildbot_master::mozilla {
        'bm109-tests1-windows':
            http_port   => 8201,
            master_type => 'tests',
            basedir     => 'tests1-windows';
    }
    include fw::profiles::buildbot_master
    include toplevel::server::buildmaster::mozilla
}

node 'buildbot-master110.bb.releng.scl3.mozilla.com' {
    $aspects       = [ 'high-security' ]
    $only_user_ssh = true
    buildmaster::buildbot_master::mozilla {
        'bm110-tests1-windows':
            http_port   => 8201,
            master_type => 'tests',
            basedir     => 'tests1-windows';
    }
    include fw::profiles::buildbot_master
    include toplevel::server::buildmaster::mozilla
}

node 'buildbot-master111.bb.releng.scl3.mozilla.com' {
    $aspects       = [ 'high-security' ]
    $only_user_ssh = true
    buildmaster::buildbot_master::mozilla {
        'bm111-tests1-windows':
            http_port   => 8201,
            master_type => 'tests',
            basedir     => 'tests1-windows';
    }
    include fw::profiles::buildbot_master
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

node /^log-aggregator\d+\.srv\.releng\.(mdc1|mdc2|scl3|use1|usw2)\.mozilla\.com$/ {
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

## Loaners

# Loaner for testing osx firewalling
# See bug 1369566
node 't-yosemite-r7-393.test.releng.mdc1.mozilla.com' {
    $aspects           = [ 'low-security' ]
    $pin_puppet_server = 'releng-puppet2.srv.releng.scl3.mozilla.com'
    $pin_puppet_env    = 'jwatkins'
    include toplevel::base
}

# Loaner for testing pip and python update
# See Bug 1388816
node 't-yosemite-r7-394.test.releng.mdc1.mozilla.com' {
    $aspects           = [ 'low-security' ]
    $slave_trustlevel  = 'try'
    $pin_puppet_server = 'releng-puppet2.srv.releng.scl3.mozilla.com'
    $pin_puppet_env    = 'dcrisan'
    include fw::profiles::osx_taskcluster_worker
    include toplevel::base
    include generic_worker::disabled
}

# Loaner for testing security patches
# See Bug 1433165 and Bug 1385050

node 'relops-patching1.srv.releng.mdc1.mozilla.com' {
    $aspects = [ 'low-security' ]
    $pin_puppet_server = 'releng-puppet2.srv.releng.scl3.mozilla.com'
    $pin_puppet_env    = 'dcrisan'
    include toplevel::server
}

# Loaner for dividehex
node 't-linux64-ms-279.test.releng.mdc1.mozilla.com' {
    $aspects = [ 'low-security' ]
    include toplevel::server
}

# Loaner for dcrisan; Bug 1410207
node 't-linux64-ms-280.test.releng.mdc1.mozilla.com' {
    $aspects = [ 'low-security' ]
    # $pin_puppet_server = 'releng-puppet2.srv.releng.scl3.mozilla.com'
    # $pin_puppet_env    = 'dcrian'
    include toplevel::server
}

# Loaner for dividehex; bug 1445842 and 1447766
node 'ds-test1.srv.releng.mdc2.mozilla.com' {
    $aspects = [ 'low-security' ]
    include toplevel::server
}
