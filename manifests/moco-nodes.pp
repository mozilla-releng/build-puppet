# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

## foopies

node /foopy\d+.tegra.releng.scl3.mozilla.com/ {
    include toplevel::server::foopy
}

node /foopy\d+.build.scl1.mozilla.com/ {
    include toplevel::server::foopy
}

node /foopy\d+.p\d+.releng.scl1.mozilla.com/ {
    include toplevel::server::foopy
}

## testers

node /talos-r4-snow-\d+.build.scl1.mozilla.com/ {
    $slave_trustlevel = 'try'
    include toplevel::slave::test::gpu
}

node /talos-r4-lion-\d+.build.scl1.mozilla.com/ {
    $slave_trustlevel = 'try'
    include toplevel::slave::test::gpu
}

node /talos-mtnlion-r5-\d+.test.releng.scl3.mozilla.com/ {
    $slave_trustlevel = 'try'
    include toplevel::slave::test::gpu
}

node /t-mavericks-r5-\d+.test.releng.scl3.mozilla.com/ {
    $slave_trustlevel = 'try'
    include toplevel::slave::test::gpu
}

node /tst-.*\.build\.aws-.*\.mozilla\.com/ {
    $slave_trustlevel = 'try'
    # Make sure we get our /etc/hosts set up
    class {
        "network::aws": stage => network,
    }
    include toplevel::slave::test::headless
}

node /tst-.*\.test\.releng\.(use1|usw2)\.mozilla\.com/ {
    $slave_trustlevel = 'try'
    # Make sure we get our /etc/hosts set up
    class {
        "network::aws": stage => network,
    }
    include toplevel::slave::test::headless
}

node /talos-linux\d+-ix-\d+\.test\.releng\.scl3\.mozilla\.com/ {
    $slave_trustlevel = 'try'
    include toplevel::slave::test::gpu
}

node /t-w732-ix-\d+.wintest.releng.scl3.mozilla.com/ {
    include toplevel::base
}

## builders

node /bld-linux64-ix-0(\d+).build.scl1.mozilla.com/ {
    # determine the slave's trustlevel from slavealloc; this case is only
    # required in the "old" datacenters; in new datacenters, trustlevel is
    # based on VLAN atom.
    if $clientcert =~ /bld-linux64-ix-0(\d+).build.scl1.mozilla.com/ {
        if $1 <= 26 {
            # decommed
        } elsif $1 <= 37 {
            $slave_trustlevel = 'core'
        } elsif $1 <= 53 {
            $slave_trustlevel = 'try'
        }
    }
    include toplevel::slave::build::mock
}

node /b-linux64-hp-0*(\d+).build.scl1.mozilla.com/ {
    $slave_trustlevel = 'try'
    include toplevel::slave::build::mock
}

node /bld-centos6-hp-0*(\d+).build.scl1.mozilla.com/ {
    # determine the slave's trustlevel from slavealloc; this case is only
    # required in the "old" datacenters; in new datacenters, trustlevel is
    # based on VLAN atom.
    if $clientcert =~ /bld-centos6-hp-0*(\d+).build.scl1.mozilla.com/ {
        if $1 <= 19 {
            $slave_trustlevel = 'core'
        } elsif $1 <= 42 {
            $slave_trustlevel = 'try'
        }
    }
    include toplevel::slave::build::mock
}

node /bld-lion-r5-\d+.try.releng.scl3.mozilla.com/ {
    $slave_trustlevel = 'try'
    include toplevel::slave::build::standard
}

node /bld-lion-r5-\d+.build.releng.scl3.mozilla.com/ {
    $slave_trustlevel = 'core'
    include toplevel::slave::build::standard
}

node /bld-.*\.build\.releng\.(use1|usw2)\.mozilla.com/ {
    $slave_trustlevel = 'core'
    # Make sure we get our /etc/hosts set up
    class {
        "network::aws": stage => network,
    }
    include toplevel::slave::build::mock
    include diamond
    include instance_metadata::diamond
}

node /try-.*\.try\.releng\.(use1|usw2)\.mozilla.com/ {
    $slave_trustlevel = 'try'
    # Make sure we get our /etc/hosts set up
    class {
        "network::aws": stage => network,
    }
    include toplevel::slave::build::mock
    include diamond
    include instance_metadata::diamond
}

node /dev-.*\.dev\.releng\.(use1|usw2)\.mozilla.com/ {
    # dev-* hosts are *always* staging
    $slave_trustlevel = 'try'
    # Make sure we get our /etc/hosts set up
    class {
        "network::aws": stage => network,
    }
    include toplevel::slave::build::mock
    include diamond
    include instance_metadata::diamond
}

## signing

node /signing[456].srv.releng.scl3.mozilla.com/ {
    include toplevel::server::signing
}

node /mac-signing[12].srv.releng.scl3.mozilla.com/ {
    include toplevel::server::signing
}

node /mac-signing[34].build.scl1.mozilla.com/ {
    include toplevel::server::signing
}

## puppetmasters

node /puppetmaster-\d+\..*\.aws-.*\.mozilla\.com/ {
    include toplevel::server::puppetmaster
}
node "releng-puppet1.srv.releng.scl3.mozilla.com" {
    include toplevel::server::puppetmaster
}
node "releng-puppet2.srv.releng.scl3.mozilla.com" {
    include toplevel::server::puppetmaster
}
node "releng-puppet2.build.scl1.mozilla.com" {
    include toplevel::server::puppetmaster
}
node /releng-puppet\d\.srv\.releng\.(use1|usw2)\.mozilla\.com/ {
    include toplevel::server::puppetmaster
}

## casper imaging servers

node /casper-fs-\d+\.srv\.releng\.scl3\.mozilla\.com/ {
    include toplevel::server
    include casper::fileserver
}

node /casper-jss-\d+\.srv\.releng\.scl3\.mozilla\.com/ {
    include toplevel::server
}

node /casper-netboot-\d+\.srv\.releng\.scl3\.mozilla\.com/ {
    include toplevel::server
}

## Misc servers

node "aws-manager1.srv.releng.scl3.mozilla.com" {
    include toplevel::server
}

## slaveapi

node "slaveapi1.srv.releng.scl3.mozilla.com" {
    include toplevel::server::slaveapi
}

node "slaveapi-dev1.srv.releng.scl3.mozilla.com" {
    $aspects = [ "dev" ]
    include toplevel::server::slaveapi
}

## mozpool servers

node "mobile-imaging-stage1.p127.releng.scl1.mozilla.com" {
    $aspects = [ "staging" ]
    $is_bmm_admin_host = true
    include toplevel::server::mozpool
    users::root::extra_authorized_key {
        'mcote': ;
    }
}

node /mobile-imaging-\d+\.p\d+\.releng\.scl1\.mozilla\.com/ {
    $is_bmm_admin_host = $fqdn ? { /^mobile-imaging-001/ => true, default => false }
    include toplevel::server::mozpool
    users::root::extra_authorized_key {
        'mcote': ;
    }
}

## buildbot masters

node "dev-master1.srv.releng.scl3.mozilla.com" {
    include toplevel::server::buildmaster::mozilla
    # Bug 975004 - Grant pkewisch access to dev-master1
    realize(Users::Person["pkewisch"])
    users::root::extra_authorized_key {
        'pkewisch': ;
    }
    users::builder::extra_authorized_key {
        'pkewisch': ;
    }
}

node "buildbot-master51.srv.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm51-tests1-linux":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master52.srv.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm52-tests1-linux":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master53.srv.releng.usw2.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm53-tests1-linux":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master54.srv.releng.usw2.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm54-tests1-linux":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master55.srv.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm55-try1":
            http_port => 8101,
            master_type => "try",
            basedir => "try1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master56.srv.releng.usw2.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm56-try1":
            http_port => 8101,
            master_type => "try",
            basedir => "try1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master57.srv.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm57-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master58.srv.releng.usw2.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm58-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
}
node "buildbot-master59.srv.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm59-try1":
            http_port => 8101,
            master_type => "try",
            basedir => "try1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master60.srv.releng.usw2.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm60-try1":
            http_port => 8101,
            master_type => "try",
            basedir => "try1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master61.srv.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm61-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
    include selfserve_agent
}

node "buildbot-master62.srv.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm62-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
    include selfserve_agent
}

node "buildbot-master63.srv.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm63-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master64.srv.releng.usw2.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm64-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master65.srv.releng.usw2.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm65-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
    include selfserve_agent
    include slaverebooter
}

node "buildbot-master66.srv.releng.usw2.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm66-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
    include toplevel::server::gaia_bumper
    include toplevel::server::b2g_bumper
    include selfserve_agent
}

node "buildbot-master67.srv.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm67-tests1-linux":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master68.srv.releng.usw2.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm68-tests1-linux":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master69.srv.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm69-tests1-windows":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-windows";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master70.srv.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm70-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master71.srv.releng.use1.mozilla.com" {
    # Free Master
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master72.srv.releng.usw2.mozilla.com" {
    # Free Master
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master73.srv.releng.usw2.mozilla.com" {
    # Free Master
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master74.srv.releng.usw2.mozilla.com" {
    # Free Master
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master75.srv.releng.use1.mozilla.com" {
    # Free Master
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master76.srv.releng.use1.mozilla.com" {
    # Free Master
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master77.srv.releng.use1.mozilla.com" {
    # Free Master
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master78.srv.releng.usw2.mozilla.com" {
    # Free Master
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master79.srv.releng.usw2.mozilla.com" {
    # Free Master
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master80.srv.releng.usw2.mozilla.com" {
    # Free Master
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master81.srv.releng.scl3.mozilla.com" {
    include toplevel::server
    include toplevel::server::buildmaster::mozilla
    include releaserunner
    include selfserve_agent
    include buildmaster::db_maintenance
    include bouncer_check
    buildmaster::buildbot_master::mozilla {
        "bm81-build_scheduler":
            master_type => "scheduler",
            basedir => "build_scheduler";
        "bm81-tests_scheduler":
            master_type => "scheduler",
            basedir => "tests_scheduler";
    }
}

node "buildbot-master82.srv.releng.scl3.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm82-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master83.srv.releng.scl3.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm83-try1":
            http_port => 8101,
            master_type => "try",
            basedir => "try1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master84.srv.releng.scl3.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm84-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master85.srv.releng.scl3.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm85-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master86.srv.releng.scl3.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm86-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster::mozilla
}


node "buildbot-master87.srv.releng.scl3.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm87-try1":
            http_port => 8101,
            master_type => "try",
            basedir => "try1";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master88.srv.releng.scl3.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm88-tests1-tegra":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-tegra";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master89.srv.releng.scl3.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm89-tests1-panda":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-panda";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master90.srv.releng.use1.mozilla.com" {
    # Free Master
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master91.srv.releng.usw2.mozilla.com" {
    # Free Master
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master92.srv.releng.use1.mozilla.com" {
    # Free Master
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master93.srv.releng.usw2.mozilla.com" {
    # Free Master
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master94.srv.releng.use1.mozilla.com" {
    # Free Master
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master95.srv.releng.usw2.mozilla.com" {
    # Free Master
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master96.srv.releng.use1.mozilla.com" {
    # Free Master
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master97.srv.releng.usw2.mozilla.com" {
    # Free Master
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master98.srv.releng.use1.mozilla.com" {
    # Free Master
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master99.srv.releng.scl3.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm99-tests1-tegra":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-tegra";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master100.srv.releng.scl3.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm100-tests1-panda":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-panda";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master101.srv.releng.scl3.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm101-tests1-panda":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-panda";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master102.srv.releng.scl3.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm102-tests1-panda":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-panda";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master103.srv.releng.scl3.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm103-tests1-linux":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master104.srv.releng.scl3.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm104-tests1-linux":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master105.srv.releng.scl3.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm105-tests1-linux":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master106.srv.releng.scl3.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm106-tests1-macosx":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-macosx";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master107.srv.releng.scl3.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm107-tests1-macosx":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-macosx";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master108.srv.releng.scl3.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm108-tests1-macosx":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-macosx";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master109.srv.releng.scl3.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm109-tests1-windows":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-windows";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master110.srv.releng.scl3.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm110-tests1-windows":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-windows";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master111.srv.releng.scl3.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm111-tests1-windows":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-windows";
    }
    include toplevel::server::buildmaster::mozilla
}

node "buildbot-master112.srv.releng.scl3.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm112-tests1-windows":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-windows";
    }
    include toplevel::server::buildmaster::mozilla
}

# Package Builders

node "ubuntu64packager1.srv.releng.use1.mozilla.com" {
    include toplevel::server::pkgbuilder
}

node "rpmpackager1.srv.releng.use1.mozilla.com" {
    include toplevel::server::pkgbuilder
}

node "openstack1.relabs.releng.scl3.mozilla.com" {
    include toplevel::server
}

# Loaners

node "talos-linux64-ix-001.test.releng.scl3.mozilla.com" {
    include toplevel::slave::test::gpu
    users::root::extra_authorized_key {
        'gbrown': ;
    }
    users::builder::extra_authorized_key {
        'gbrown': ;
    }
}
