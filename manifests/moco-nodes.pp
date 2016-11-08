# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

## testers

# linux64 and OS X

node /t.*-\d+\.test\.releng\.scl3\.mozilla\.com/ {
    # hosts starting with t and ending in -digit.test.releng.scl3.mozilla.com
    $aspects = [ 'low-security' ]
    $slave_trustlevel = 'try'
    include toplevel::slave::releng::test::gpu
}

# AWS

node /tst-.*\.test\.releng\.(use1|usw2)\.mozilla\.com/ {
    # tst-anything in any region of the test.releng mozilla zones
    $aspects = [ 'low-security' ]
    $slave_trustlevel = 'try'
    include toplevel::slave::releng::test::headless
}

# Windows
node /t-w732.*\.(wintest|test)\.releng\.(scl3|use1|usw2)\.mozilla.com/{
    # windows 7 nodes in wintest.releng.scl3.mozilla.com
    $aspects = [ 'low-security' ]
    $slave_trustlevel = 'try'
    include toplevel::slave
}
node /g-w732.*\.(wintest|test)\.releng\.(scl3|use1|usw2)\.mozilla.com/{
    # windows 7 nodes in wintest.releng.scl3.mozilla.com
    $aspects = [ 'low-security' ]
    $slave_trustlevel = 'try'
    include toplevel::slave
}

# Node declaration is for Win 7 development
# To keep development and production catalogs separate
node /d-w732.*\.(wintest|test)\.releng\.(scl3|use1|usw2)\.mozilla.com/{
    # windows 7 nodes in wintest.releng.scl3.mozilla.com
    $aspects = [ 'low-security' ]
    $slave_trustlevel = 'try'
    include toplevel::slave::releng::test
}

# windows 10 test hardware
node /t-w1064.*\.wintest\.releng\.scl3\.mozilla\.com/ {
    $aspects = [ 'low-security' ]
    include toplevel::slave
}

# windows 10 test AWS instances
node /(g|t)-w10.*\.test\.releng\.(use1|usw2)\.mozilla\.com/ {
    $aspects = [ 'low-security' ]
    include toplevel::slave
}

## builders

# Windows
node /b-2008.*\.(winbuild|build)\.releng\.(scl3|use1|usw2)\.mozilla.com/{
    $aspects = [ 'low-security' ]
    $slave_trustlevel = 'core'
    include toplevel::slave::releng::build
}

# linux64
node /b-linux64-\w+-\d+.build.releng.scl3.mozilla.com/ {
    # any b-linux64-(something)-digit host in the scl3 build zone
    $aspects = [ 'low-security' ]
    $slave_trustlevel = 'core'
    include toplevel::slave::releng::build::mock
}

node /bld-.*\.build\.releng\.(use1|usw2)\.mozilla.com/ {
    # any bld-(something) host in the use1 and usw2 releng build zones
    $aspects = [ 'low-security' ]
    $slave_trustlevel = 'core'
    include toplevel::slave::releng::build::mock
}

node /av-linux64.*\.build\.releng\.(use1|usw2)\.mozilla\.com/ {
    $aspects = [ 'low-security' ]
    $slave_trustlevel = 'core'
    include toplevel::slave::releng::build::mock::av
}

# OS X
node /bld-lion-r5-\d+\.build\.releng\.scl3\.mozilla\.com/ {
    # any bld-lion-r5-(digit) hosts in the scl3 build zone
    $slave_trustlevel = 'core'
    $aspects = [ 'low-security' ]
    include toplevel::slave::releng::build::standard
}

## try builders

# Windows
node /(b|y|try)-2008-.*\.(try|wintry).releng.(use1|usw2|scl3).mozilla.com/ {
    $slave_trustlevel = 'try'
    $aspects = [ 'low-security' ]
    include toplevel::slave::releng::build
}

# Datacenter Windows builder for testing
node "ix-mn-w0864-002.wintest.releng.scl3.mozilla.com" {
    $aspects = [ 'low-security' ]
    $slave_trustlevel = 'try'
    include toplevel::slave::releng::build
}

# linux64
node /b-linux64-\w+-\d+.try.releng.scl3.mozilla.com/ {
    # any b-linux64-(something)-digit host in the scl3 try zone
    $aspects = [ 'low-security' ]
    $slave_trustlevel = 'try'
    include toplevel::slave::releng::build::mock
}

node /(dev|try)-.*\.(dev|try)\.releng\.(use1|usw2)\.mozilla.com/ {
    # any dev or try node in the dev or try zones of use1 and usw2
    # dev-* hosts are *always* staging
    $aspects = [ 'low-security' ]
    $slave_trustlevel = 'try'
    include toplevel::slave::releng::build::mock
}

# OS X
node /bld-lion-r5-\d+.try.releng.scl3.mozilla.com/ {
    # any bld-lion-r5-(digit) hosts in the scl3 try zone
    $aspects = [ 'low-security' ]
    $slave_trustlevel = 'try'
    include toplevel::slave::releng::build::standard
}

## signing servers

node /mac-(v2-|)signing\d+\.srv\.releng\.scl3\.mozilla\.com/ {
    # mac signing servers
    $aspects = [ 'maximum-security' ]
    $timezone = "GMT"
    include toplevel::server::signing
}

node /signing\d+\.srv\.releng\.scl3\.mozilla\.com/ {
    # linux signing servers
    $aspects = [ 'maximum-security' ]
    $timezone = "UTC"
    include toplevel::server::signing
}

## puppetmasters

node /releng-puppet\d+\.srv\.releng\.(scl3|use1|usw2)\.mozilla\.com/ {
    $aspects = [ 'maximum-security' ]
    include toplevel::server::puppetmaster
}

node "releng-puppet2.srv.releng.scl3.mozilla.com" {
    $aspects = [ 'maximum-security' ]
    include toplevel::server::puppetmaster
    class {
        'bacula_client':
            cert => secret('releng_puppet2_srv_releng_scl3_bacula_cert'),
            key => secret('releng_puppet2_srv_releng_scl3_bacula_key');
    }
}

## deploystudio servers

node "install.build.releng.scl3.mozilla.com" {
    $aspects = [ "maximum-security" ]
    include toplevel::server::deploystudio
    class {
        'bacula_client':
            cert => secret('install_build_releng_scl3_bacula_cert'),
            key => secret('install_build_releng_scl3_bacula_key');
    }
}

node "install.test.releng.scl3.mozilla.com" {
    $aspects = [ "maximum-security" ]
    include toplevel::server::deploystudio
    class {
        'bacula_client':
            cert => secret('install_test_releng_scl3_bacula_cert'),
            key => secret('install_test_releng_scl3_bacula_key');
    }
}

## casper imaging servers

node /casper-fs-\d+\.srv\.releng\.scl3\.mozilla\.com/ {
    # casper fileserver
    $aspects = [ "low-security" ]
    include toplevel::server
    include casper::fileserver
}

node /casper-jss-\d+\.srv\.releng\.scl3\.mozilla\.com/ {
    $aspects = [ "low-security" ]
    include toplevel::server
}

node /casper-netboot-\d+\.srv\.releng\.scl3\.mozilla\.com/ {
    $aspects = [ "low-security" ]
    include toplevel::server
}

## Misc servers

node /dev-linux64-ec2-001.dev.releng.use1.mozilla.com/ {
    # any dev or try node in the dev or try zones of use1 and usw2
    # dev-* hosts are *always* staging
    $aspects = [ 'low-security' ]
    $slave_trustlevel = 'try'
    include toplevel::slave::releng::build::mock
    users::root::extra_authorized_key {
        'sledru': ;
    }
}

node /cruncher-aws\.srv\.releng\.(use1|usw2)\.mozilla\.com/ {
    $aspects = [ "high-security" ]
    include toplevel::server::cruncher
}

# aws-manager

node /aws-manager\d+\.srv\.releng\.scl3\.mozilla\.com/ {
    $aspects = [ 'high-security' ]
    include toplevel::server::aws_manager

    # Bug 1265758 - Add acccess to the following accounts to dev-master2
    realize(Users::Person["ashiue"])
    realize(Users::Person["gchang"])
    realize(Users::Person["ihsiao"])

    users::buildduty::extra_authorized_key {
        'ashiue': ;
        'gchang': ;
        'ihsiao': ;
    }
}

# buildduty-tools

node /buildduty-tools\.srv\.releng\.(use1|usw2)\.mozilla\.com/ {
    $aspects = [ 'medium-security' ]
    include toplevel::server::buildduty_tools
}

# slaveapi

node "slaveapi1.srv.releng.scl3.mozilla.com" {
    $aspects = [ 'high-security' ]
    include toplevel::server::slaveapi
}

node "slaveapi-dev1.srv.releng.scl3.mozilla.com" {
    $aspects = [ 'high-security', "dev" ]
    include toplevel::server::slaveapi
}

# Proxxy

node /proxxy\d+\.srv\.releng\.(scl3|use1|usw2)\.mozilla\.com/ {
    $aspects = [ 'high-security' ]
    include toplevel::server::proxxy
}

# Package Builders

node /.*packager\d+\.srv\.releng\.use1\.mozilla\.com/ {
    # RPM and DPKG package servers
    $aspects = [ "low-security" ]
    include toplevel::server::pkgbuilder
}

## buildbot masters

node "dev-master2.bb.releng.use1.mozilla.com" {
    $aspects = [ 'high-security' ]
    include toplevel::server::buildmaster::mozilla

    # Bug 975004 - Grant pkewisch access to dev-master1
    # Bug 1265758 - Add acccess to the following accounts to dev-master2
    realize(Users::Person["pkewisch"])
    realize(Users::Person["sledru"])
    realize(Users::Person["ashiue"])
    realize(Users::Person["gchang"])
    realize(Users::Person["ihsiao"])
    users::root::extra_authorized_key {
        'pkewisch': ;
        'sledru': ;
    }
    users::builder::extra_authorized_key {
        'pkewisch': ;
        'sledru': ;
    }
}

node "buildbot-master01.bb.releng.use1.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm01-tests1-linux32":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux32";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master02.bb.releng.use1.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm02-tests1-linux32":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux32";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master03.bb.releng.use1.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm03-tests1-linux32":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux32";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master04.bb.releng.usw2.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm04-tests1-linux32":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux32";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master05.bb.releng.usw2.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm05-tests1-linux32":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux32";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master06.bb.releng.usw2.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm06-tests1-linux32":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux32";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master07.bb.releng.usw2.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm07-tests1-linux32":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux32";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master08.bb.releng.use1.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm08-tests1-linux32":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux32";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master51.bb.releng.use1.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm51-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master52.bb.releng.use1.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm52-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master53.bb.releng.usw2.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm53-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master54.bb.releng.usw2.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm54-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master67.bb.releng.use1.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm67-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master68.bb.releng.usw2.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm68-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master69.bb.releng.use1.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm69-tests1-windows":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-windows";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master70.bb.releng.use1.mozilla.com" {
    $aspects = [ 'high-security' ]
    $buildbot_bridge_env = "prod"
    buildmaster::buildbot_master::mozilla {
        "bm70-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
    include toplevel::mixin::selfserve_agent
    include toplevel::mixin::buildbot_bridge
}

node "buildbot-master71.bb.releng.use1.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm71-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
    include toplevel::mixin::selfserve_agent
}

node "buildbot-master72.bb.releng.usw2.mozilla.com" {
    $aspects = [ 'high-security' ]
    $buildbot_bridge_env = "prod"
    buildmaster::buildbot_master::mozilla {
        "bm72-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
    include toplevel::mixin::selfserve_agent
    include toplevel::mixin::buildbot_bridge
}

node "buildbot-master73.bb.releng.usw2.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm73-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
    include toplevel::mixin::selfserve_agent
}

node "buildbot-master74.bb.releng.usw2.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm74-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
    # disabled per Callek
    #include toplevel::mixin::slaverebooter
}

node "buildbot-master75.bb.releng.use1.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm75-try1":
            http_port => 8101,
            master_type => "try",
            basedir => "try1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master76.bb.releng.use1.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm76-try1":
            http_port => 8101,
            master_type => "try",
            basedir => "try1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master77.bb.releng.use1.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm77-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master78.bb.releng.usw2.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm78-try1":
            http_port => 8101,
            master_type => "try",
            basedir => "try1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master79.bb.releng.usw2.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm79-try1":
            http_port => 8101,
            master_type => "try",
            basedir => "try1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master81.bb.releng.scl3.mozilla.com" {
    $aspects = [ 'high-security' ]
    $releaserunner_env = "prod"
    buildmaster::buildbot_master::mozilla {
        "bm81-build_scheduler":
            master_type => "scheduler",
            basedir => "build_scheduler";
        "bm81-tests_scheduler":
            master_type => "scheduler",
            basedir => "tests_scheduler";
    }
    include toplevel::server::buildmaster::mozilla
    include toplevel::mixin::selfserve_agent
    include toplevel::mixin::releaserunner
    include toplevel::mixin::buildmaster_db_maintenance
    include toplevel::mixin::bouncer_check
}

node "buildbot-master82.bb.releng.scl3.mozilla.com" {
    $aspects = [ 'high-security' ]
    $buildbot_bridge_env = "prod"
    buildmaster::buildbot_master::mozilla {
        "bm82-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
    include toplevel::mixin::buildbot_bridge
}

node "buildbot-master83.bb.releng.scl3.mozilla.com" {
    $aspects = [ 'high-security' ]
    $releaserunner_env = "dev"
    buildmaster::buildbot_master::mozilla {
        "bm83-try1":
            http_port => 8101,
            master_type => "try",
            basedir => "try1";
    }
    include toplevel::server::buildmaster::mozilla
    include toplevel::mixin::releaserunner
}

node "buildbot-master84.bb.releng.scl3.mozilla.com" {
    $aspects = [ 'high-security' ]
    $buildbot_bridge_env = "dev"
    buildmaster::buildbot_master::mozilla {
        "bm84-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
    include toplevel::mixin::buildbot_bridge
}

node "buildbot-master85.bb.releng.scl3.mozilla.com" {
    $aspects = [ 'high-security' ]
    $releaserunner_env = "prod"
    buildmaster::buildbot_master::mozilla {
        "bm85-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
    include toplevel::mixin::releaserunner
}

node "buildbot-master86.bb.releng.scl3.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm86-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master87.bb.releng.scl3.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm87-try1":
            http_port => 8101,
            master_type => "try",
            basedir => "try1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master91.bb.releng.usw2.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm91-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
    include toplevel::mixin::funsize_scheduler
}

node "buildbot-master94.bb.releng.use1.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm94-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
    include toplevel::mixin::funsize_scheduler
}

node "buildbot-master103.bb.releng.scl3.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm103-tests1-linux":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux";
    }
    include toplevel::server::buildmaster::mozilla
    include toplevel::mixin::funsize_scheduler
}

node "buildbot-master104.bb.releng.scl3.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm104-tests1-linux":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master105.bb.releng.scl3.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm105-tests1-linux":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master106.bb.releng.scl3.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm106-tests1-macosx":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-macosx";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master107.bb.releng.scl3.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm107-tests1-macosx":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-macosx";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master108.bb.releng.scl3.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm108-tests1-macosx":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-macosx";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master109.bb.releng.scl3.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm109-tests1-windows":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-windows";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master110.bb.releng.scl3.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm110-tests1-windows":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-windows";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master111.bb.releng.scl3.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm111-tests1-windows":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-windows";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master112.bb.releng.scl3.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm112-tests1-windows":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-windows";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master113.bb.releng.use1.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm113-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master114.bb.releng.use1.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm114-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master115.bb.releng.usw2.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm115-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master116.bb.releng.usw2.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm116-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master117.bb.releng.use1.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm117-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master118.bb.releng.usw2.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm118-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master119.bb.releng.scl3.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm119-tests1-windows":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-windows";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master120.bb.releng.use1.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm120-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master121.bb.releng.use1.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm121-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master122.bb.releng.usw2.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm122-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master123.bb.releng.usw2.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm123-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master124.bb.releng.use1.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm124-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master125.bb.releng.usw2.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm125-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master126.bb.releng.scl3.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm126-tests1-windows":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-windows";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master127.bb.releng.scl3.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm127-tests1-windows":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-windows";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master128.bb.releng.use1.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm128-tests1-windows":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-windows";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master129.bb.releng.usw2.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm129-tests1-windows":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-windows";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master130.bb.releng.use1.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm130-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master131.bb.releng.usw2.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm131-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master132.bb.releng.scl3.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm132-tests1-macosx":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-macosx";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master133.bb.releng.scl3.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm133-tests1-macosx":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-macosx";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master134.bb.releng.scl3.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm134-tests1-macosx":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-macosx";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master135.bb.releng.scl3.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm135-tests1-macosx":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-macosx";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master136.bb.releng.scl3.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm136-tests1-macosx":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-macosx";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master137.bb.releng.use1.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm137-tests1-windows":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-windows";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master138.bb.releng.use1.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm138-tests1-windows":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-windows";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master139.bb.releng.usw2.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm139-tests1-windows":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-windows";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master140.bb.releng.usw2.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm140-tests1-windows":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-windows";
    }
    include toplevel::server::buildmaster::mozilla
}
node "buildbot-master141.bb.releng.use1.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm141-tests1-linux32":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux32";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master142.bb.releng.usw2.mozilla.com" {
    $aspects = [ 'high-security' ]
    buildmaster::buildbot_master::mozilla {
        "bm142-tests1-linux32":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux32";
    }
    include toplevel::server::buildmaster::mozilla
}

node /log-aggregator\d+\.srv\.releng\.(scl3|use1|usw2)\.mozilla\.com/ {
    $aspects = [ 'high-security' ]
    $is_log_aggregator_host = "true"
    include toplevel::server::log_aggregator
}

# Signing workers
node /signingworker-.*\.srv\.releng\..*\.mozilla\.com/ {
    $aspects = [ 'maximum-security' ]
    include toplevel::server::signingworker
}

# Signing scriptworkers
node /signing-linux-.*\.srv\.releng\..*\.mozilla\.com/ {
    $aspects = [ 'maximum-security' ]
    $timezone = "UTC"
    include toplevel::server::signingscriptworker
}

# Balrog scriptworkers
node /balrogworker-.*\.srv\.releng\..*\.mozilla\.com/ {
    $aspects = [ 'maximum-security' ]
    $balrogworker_env = "dev"
    $timezone = "UTC"
    include toplevel::server::balrogscriptworker
}

# Beetmover scriptworkers
node /beetmoverworker-.*\.srv\.releng\..*\.mozilla\.com/ {
    $aspects = [ 'maximum-security' ]
    $beetmoverworker_env = "dev"
    $timezone = "UTC"
    include toplevel::server::beetmoverscriptworker
}

## Loaners
