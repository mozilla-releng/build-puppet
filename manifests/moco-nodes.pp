# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

## foopies

node /foopy\d+\.\w+\.releng\.scl3\.mozilla\.com/ {
    # covers pN and tegra vlans
    include toplevel::server::foopy
}

## testers

# linux64 and OS X
node /t.*-\d+\.test\.releng\.scl3\.mozilla\.com/ {
    # hosts starting with t and ending in -digit.test.releng.scl3.mozilla.com
    $node_security_level = 'low'
    $slave_trustlevel = 'try'
    include toplevel::slave::releng::test::gpu
}

# AWS

node /tst-.*\.test\.releng\.(use1|usw2)\.mozilla\.com/ {
    # tst-anything in any region of the test.releng mozilla zones
    $node_security_level = 'low'
    $slave_trustlevel = 'try'
    include toplevel::slave::releng::test::headless
}

# Windows
node /t-w732-ix-\d+.wintest.releng.scl3.mozilla.com/ {
    # windows 7 nodes in wintest.releng.scl3.mozilla.com
    $node_security_level = 'low'
    include toplevel::base
}

## builders

# Windows
node /b-2008.*\.build\.releng\.(use1|usw2)\.mozilla.com/{
    $node_security_level = 'low'
    $slave_trustlevel = 'try'
    include toplevel::slave::releng::build
}
    

# linux64
node /b-linux64-\w+-\d+.build.releng.scl3.mozilla.com/ {
    # any b-linux64-(something)-digit host in the scl3 build zone
    $node_security_level = 'low'
    $slave_trustlevel = 'core'
    include toplevel::slave::releng::build::mock
}

node /bld-.*\.build\.releng\.(use1|usw2)\.mozilla.com/ {
    # any bld-(something) host in the use1 and usw2 releng build zones
    $node_security_level = 'low'
    $slave_trustlevel = 'core'
    include toplevel::slave::releng::build::mock
    include diamond
    include instance_metadata::diamond
}

# OS X
node /bld-lion-r5-\d+\.build\.releng\.scl3\.mozilla\.com/ {
    # any bld-lion-r5-(digit) hosts in the scl3 build zone
    $slave_trustlevel = 'core'
    $node_security_level = 'low'
    include toplevel::slave::releng::build::standard
}

## try builders

# Windows
node /b-2008-\w+-\d+.winbuild.releng.scl3.mozilla.com/ {
    $slave_trustlevel = 'try'
    $node_security_level = 'low'
    include toplevel::slave::releng::build
}

node /b-2008.*\.(dev|try)\.releng\.(use1|usw2)\.mozilla.com/{
    $slave_trustlevel = 'try'
    $node_security_level = 'low'
    include toplevel::slave::releng::build
}

# Datacenter Windows builder for testing
node "ix-mn-w0864-002.wintest.releng.scl3.mozilla.com" {
    $node_security_level = 'low'
    $slave_trustlevel = 'try'
    include toplevel::slave::releng::build
}

# linux64
node /b-linux64-\w+-\d+.try.releng.scl3.mozilla.com/ {
    # any b-linux64-(something)-digit host in the scl3 try zone
    $node_security_level = 'low'
    $slave_trustlevel = 'try'
    include toplevel::slave::releng::build::mock
}

node /(dev|try)-.*\.(dev|try)\.releng\.(use1|usw2)\.mozilla.com/ {
    # any dev or try node in the dev or try zones of use1 and usw2
    # dev-* hosts are *always* staging
    $node_security_level = 'low'
    $slave_trustlevel = 'try'
    include toplevel::slave::releng::build::mock
    include diamond
    include instance_metadata::diamond
}

# OS X
node /bld-lion-r5-\d+.try.releng.scl3.mozilla.com/ {
    # any bld-lion-r5-(digit) hosts in the scl3 try zone
    $node_security_level = 'low'
    $slave_trustlevel = 'try'
    include toplevel::slave::releng::build::standard
}

## signing servers

node /(mac-(v2-|)|)signing\d+\.srv\.releng\.scl3\.mozilla\.com/ {
    # all mac and linux signing servers
    $node_security_level = 'maximum'
    include toplevel::server::signing
}

## puppetmasters

node /releng-puppet\d+\.srv\.releng\.(scl3|use1|usw2)\.mozilla\.com/ {
    $node_security_level = 'high'
    include toplevel::server::puppetmaster
}

node "releng-puppet2.srv.releng.scl3.mozilla.com" {
    $node_security_level = 'high'
    include toplevel::server::puppetmaster
    class {
        'bacula_client':
            cert => secret('releng_puppet2_srv_releng_scl3_bacula_cert'),
            key => secret('releng_puppet2_srv_releng_scl3_bacula_key');
    }
}

## deploystudio servers

node /install\.(build|test)\.releng\.scl3\.mozilla\.com/ {
    include toplevel::server::deploystudio
}

## casper imaging servers

node /casper-fs-\d+\.srv\.releng\.scl3\.mozilla\.com/ {
    # casper fileserver
    include toplevel::server
    include casper::fileserver
}

node /casper-jss-\d+\.srv\.releng\.scl3\.mozilla\.com/ {
    include toplevel::server
}

node /casper-netboot-\d+\.srv\.releng\.scl3\.mozilla\.com/ {
    include toplevel::server
}

## openstack admin servers

node /controller\d+\.admin\.cloud\.releng\.scl3\.mozilla\.com/ {
    $pin_puppet_server = "releng-puppet2.srv.releng.scl3.mozilla.com"
    $pin_puppet_env = "jwatkins"
    $aspects = [ "staging" ]
    include toplevel::server
}

node /glance-controller\d+\.admin\.cloud\.releng\.scl3\.mozilla\.com/ {
    $pin_puppet_server = "releng-puppet2.srv.releng.scl3.mozilla.com"
    $pin_puppet_env = "jwatkins"
    $aspects = [ "staging" ]
    include toplevel::server
}

node /network-node\d+\.admin\.cloud\.releng\.scl3\.mozilla\.com/ {
    $pin_puppet_server = "releng-puppet2.srv.releng.scl3.mozilla.com"
    $pin_puppet_env = "jwatkins"
    $aspects = [ "staging" ]
    include toplevel::server
}

## Misc servers

node /dev-linux64-ec2-001.dev.releng.use1.mozilla.com/ {
    # any dev or try node in the dev or try zones of use1 and usw2
    # dev-* hosts are *always* staging
    $node_security_level = 'low'
    $slave_trustlevel = 'try'
    include toplevel::slave::releng::build::mock
    include diamond
    include instance_metadata::diamond
    users::root::extra_authorized_key {
        'sledru': ;
    }
}

# aws-manager

node /aws-manager\d+\.srv\.releng\.scl3\.mozilla\.com/ {
    $node_security_level = 'high'
    include toplevel::server::aws_manager
}

# slaveapi

node "slaveapi1.srv.releng.scl3.mozilla.com" {
    $node_security_level = 'high'
    include toplevel::server::slaveapi
}

node "slaveapi-dev1.srv.releng.scl3.mozilla.com" {
    $node_security_level = 'high'
    $aspects = [ "dev" ]
    include toplevel::server::slaveapi
}

# mozpool servers

node /mobile-imaging-stage1\.p127\.releng\.scl3\.mozilla\.com/ {
    $aspects = [ "staging" ]
    $is_bmm_admin_host = $fqdn ? { /.*scl3\.mozilla\.com$/ => true, default => false }
    include toplevel::server::mozpool
    users::root::extra_authorized_key {
        'mcote': ;
    }
    shared::execonce {
        'test-exec':
            command => "/bin/touch /tmp/foo";
    }
}

node /mobile-imaging-\d+\.p\d+\.releng\.scl3\.mozilla\.com/ {
    $is_bmm_admin_host = $fqdn ? { /^mobile-imaging-001/ => true, default => false }
    include toplevel::server::mozpool
    users::root::extra_authorized_key {
        'mcote': ;
    }
}

# Proxxy

node /proxxy\d+\.srv\.releng\.(scl3|use1|usw2)\.mozilla\.com/ {
    $node_security_level = 'high'
    include toplevel::server::proxxy
}

# Package Builders

node /.*packager\d+\.srv\.releng\.use1\.mozilla\.com/ {
    # RPM and DPKG package servers
    include toplevel::server::pkgbuilder
}

## buildbot masters

node "dev-master2.bb.releng.use1.mozilla.com" {
    $node_security_level = 'high'
    include toplevel::server::buildmaster::mozilla

    # Bug 975004 - Grant pkewisch access to dev-master1
    realize(Users::Person["pkewisch"])
    realize(Users::Person["sledru"])
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
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm01-tests1-linux32":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux32";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master02.bb.releng.use1.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm02-tests1-linux32":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux32";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master03.bb.releng.use1.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm03-tests1-linux32":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux32";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master04.bb.releng.usw2.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm04-tests1-linux32":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux32";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master05.bb.releng.usw2.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm05-tests1-linux32":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux32";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master06.bb.releng.usw2.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm06-tests1-linux32":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux32";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master51.bb.releng.use1.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm51-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master52.bb.releng.use1.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm52-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master53.bb.releng.usw2.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm53-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master54.bb.releng.usw2.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm54-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master66.bb.releng.usw2.mozilla.com" {
    # Not actually a master; see
    #   https://bugzilla.mozilla.org/show_bug.cgi?id=990173
    #   https://bugzilla.mozilla.org/show_bug.cgi?id=990172
    $node_security_level = 'high'
    include toplevel::server::buildmaster::mozilla
    include toplevel::mixin::b2g_bumper
}

node "buildbot-master67.bb.releng.use1.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm67-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master68.bb.releng.usw2.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm68-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master69.bb.releng.use1.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm69-tests1-windows":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-windows";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master70.bb.releng.use1.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm70-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
    include toplevel::mixin::selfserve_agent
}

node "buildbot-master71.bb.releng.use1.mozilla.com" {
    $node_security_level = 'high'
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
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm72-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
    include toplevel::mixin::selfserve_agent
}

node "buildbot-master73.bb.releng.usw2.mozilla.com" {
    $node_security_level = 'high'
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
    $node_security_level = 'high'
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
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm75-try1":
            http_port => 8101,
            master_type => "try",
            basedir => "try1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master76.bb.releng.use1.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm76-try1":
            http_port => 8101,
            master_type => "try",
            basedir => "try1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master77.bb.releng.use1.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm77-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master78.bb.releng.usw2.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm78-try1":
            http_port => 8101,
            master_type => "try",
            basedir => "try1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master79.bb.releng.usw2.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm79-try1":
            http_port => 8101,
            master_type => "try",
            basedir => "try1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master81.bb.releng.scl3.mozilla.com" {
    $node_security_level = 'high'
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
    include toplevel::mixin::shipit_notifier
    include toplevel::mixin::buildmaster_db_maintenance
    include toplevel::mixin::bouncer_check
}

node "buildbot-master82.bb.releng.scl3.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm82-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master83.bb.releng.scl3.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm83-try1":
            http_port => 8101,
            master_type => "try",
            basedir => "try1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master84.bb.releng.scl3.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm84-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master85.bb.releng.scl3.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm85-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master86.bb.releng.scl3.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm86-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master87.bb.releng.scl3.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm87-try1":
            http_port => 8101,
            master_type => "try",
            basedir => "try1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master89.bb.releng.scl3.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm89-tests1-panda":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-panda";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master91.bb.releng.usw2.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm91-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master94.bb.releng.use1.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm94-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master100.bb.releng.scl3.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm100-tests1-panda":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-panda";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master101.bb.releng.scl3.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm101-tests1-panda":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-panda";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master102.bb.releng.scl3.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm102-tests1-panda":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-panda";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master103.bb.releng.scl3.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm103-tests1-linux":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master104.bb.releng.scl3.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm104-tests1-linux":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master105.bb.releng.scl3.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm105-tests1-linux":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master106.bb.releng.scl3.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm106-tests1-macosx":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-macosx";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master107.bb.releng.scl3.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm107-tests1-macosx":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-macosx";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master108.bb.releng.scl3.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm108-tests1-macosx":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-macosx";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master109.bb.releng.scl3.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm109-tests1-windows":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-windows";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master110.bb.releng.scl3.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm110-tests1-windows":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-windows";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master111.bb.releng.scl3.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm111-tests1-windows":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-windows";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master112.bb.releng.scl3.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm112-tests1-windows":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-windows";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master113.bb.releng.use1.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm113-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master114.bb.releng.use1.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm114-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master115.bb.releng.usw2.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm115-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master116.bb.releng.usw2.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm116-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master117.bb.releng.use1.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm117-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master118.bb.releng.usw2.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm118-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master119.bb.releng.scl3.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm119-tests1-windows":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-windows";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master120.bb.releng.use1.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm120-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master121.bb.releng.use1.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm121-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master122.bb.releng.usw2.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm122-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master123.bb.releng.usw2.mozilla.com" {
    $node_security_level = 'high'
    buildmaster::buildbot_master::mozilla {
        "bm123-tests1-linux64":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux64";
    }
    include toplevel::server::buildmaster::mozilla
}

node /log-aggregator\d+\.srv\.releng\.(scl3|use1|usw2)\.mozilla\.com/ {
    $is_log_aggregator_host = "true"
    include toplevel::server::log_aggregator
}

## Loaners

## temporary hosts Bug 1141628 and 1141626

node "bld-lion-r4-001.build.releng.scl3.mozilla.com" {
    $slave_trustlevel = 'core'
    include toplevel::slave::releng::build::standard
}

node "mac-v2-signing5.test.releng.scl3.mozilla.com" {
    $node_security_level = 'maximum'
    include toplevel::server::signing
}

