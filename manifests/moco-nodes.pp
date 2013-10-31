# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

## foopies

node /foopy\d+.build.mtv1.mozilla.com/ {
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
    include toplevel::slave::test::gpu
}

node /talos-r4-lion-\d+.build.scl1.mozilla.com/ {
    include toplevel::slave::test::gpu
}

node /talos-mtnlion-r5-\d+.test.releng.scl3.mozilla.com/ {
    include toplevel::slave::test::gpu
}

node /t-mavericks-r5-\d+.test.releng.scl3.mozilla.com/ {
    include toplevel::slave::test::gpu
}

node /tst-.*\.build\.aws-.*\.mozilla\.com/ {
    # Make sure we get our /etc/hosts set up
    class {
        "network::aws": stage => network,
    }
    include toplevel::slave::test::headless
}

node /tst-.*\.test\.releng\.(use1|usw2)\.mozilla\.com/ {
    # Make sure we get our /etc/hosts set up
    class {
        "network::aws": stage => network,
    }
    include toplevel::slave::test::headless
}

node /talos-linux\d+-ix-\d+\.test\.releng\.scl3\.mozilla\.com/ {
    include toplevel::slave::test::gpu
}

## builders

node /bld-linux64-ix-\d+.build.(scl1|mtv1).mozilla.com/ {
    include toplevel::slave::build::mock
}

node /bld-centos6-hp-\d+.build.(scl1|mtv1).mozilla.com/ {
    include toplevel::slave::build::mock
}

node /b-linux64-hp-\d+.build.(scl1|mtv1).mozilla.com/ {
    include toplevel::slave::build::mock
}

node /bld-lion-r5-\d+.(try|build).releng.scl3.mozilla.com/ {
    include toplevel::slave::build::standard
}

node /(bld|try|dev)-.*\.build\.aws-.*\.mozilla\.com/ {
    # Make sure we get our /etc/hosts set up
    class {
        "network::aws": stage => network,
    }
    include toplevel::slave::build::mock
}

node /(bld|try|dev)-.*\.(build|try|dev)\.releng\.(use1|usw2)\.mozilla.com/ {
    # Make sure we get our /etc/hosts set up
    class {
        "network::aws": stage => network,
    }
    include toplevel::slave::build::mock
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
node "releng-puppet2.build.mtv1.mozilla.com" {
    include toplevel::server::puppetmaster
}
node /releng-puppet\d\.srv\.releng\.(use1|usw2)\.mozilla\.com/ {
    include toplevel::server::puppetmaster
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

node "buildbot-master51.srv.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm51-tests1-linux":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master52.srv.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm52-tests1-linux":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master53.srv.releng.usw2.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm53-tests1-linux":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master54.srv.releng.usw2.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm54-tests1-linux":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master55.srv.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm55-try1":
            http_port => 8101,
            master_type => "try",
            basedir => "try1";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master56.srv.releng.usw2.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm56-try1":
            http_port => 8101,
            master_type => "try",
            basedir => "try1";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master57.srv.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm57-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master58.srv.releng.usw2.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm58-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster
}
node "buildbot-master59.srv.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm59-try1":
            http_port => 8101,
            master_type => "try",
            basedir => "try1";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master60.srv.releng.usw2.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm60-try1":
            http_port => 8101,
            master_type => "try",
            basedir => "try1";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master61.srv.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm61-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master62.srv.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm62-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master63.srv.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm63-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master64.srv.releng.usw2.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm64-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master65.srv.releng.usw2.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm65-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master66.srv.releng.usw2.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm66-build1":
            http_port => 8001,
            master_type => "build",
            basedir => "build1";
    }
    include toplevel::server::buildmaster
    include toplevel::server::gaia_bumper
}

node "buildbot-master67.srv.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm67-tests1-linux":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master68.srv.releng.usw2.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm68-tests1-linux":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-linux";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master69.srv.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm69-tests1-windows":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-windows";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master70.srv.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm70-tests1-windows":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-windows";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master71.srv.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm71-tests1-windows":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-windows";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master72.srv.releng.usw2.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm72-tests1-windows":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-windows";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master73.srv.releng.usw2.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm73-tests1-windows":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-windows";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master74.srv.releng.usw2.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm74-tests1-windows":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-windows";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master75.srv.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm75-tests1-macosx":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-macosx";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master76.srv.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm76-tests1-macosx":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-macosx";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master77.srv.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm77-tests1-macosx":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-macosx";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master78.srv.releng.usw2.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm78-tests1-macosx":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-macosx";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master79.srv.releng.usw2.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm79-tests1-macosx":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-macosx";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master80.srv.releng.usw2.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm80-tests1-macosx":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-macosx";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master81.srv.releng.scl3.mozilla.com" {
    include toplevel::server
    include toplevel::server::buildmaster
    include releaserunner
    include buildmaster::db_maintenance
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
    include toplevel::server::buildmaster
}

node "buildbot-master83.srv.releng.scl3.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm83-try1":
            http_port => 8101,
            master_type => "try",
            basedir => "try1";
    }
    include toplevel::server::buildmaster
}

# temporary node defs for these hosts
node /buildbot-master8[4-8].srv.releng.scl3.mozilla.com/ {
    include toplevel::server
}

node "buildbot-master89.srv.releng.scl3.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm89-tests1-panda":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-panda";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master90.srv.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm90-tests1-panda":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-panda";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master91.srv.releng.usw2.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm91-tests1-panda":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-panda";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master92.srv.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm92-tests1-panda":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-panda";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master93.srv.releng.usw2.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm93-tests1-panda":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-panda";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master94.srv.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm94-tests1-panda":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-panda";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master95.srv.releng.usw2.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm95-tests1-tegra":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-tegra";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master96.srv.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm96-tests1-tegra":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-tegra";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master97.srv.releng.usw2.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm97-tests1-tegra":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-tegra";
    }
    include toplevel::server::buildmaster
}

node "buildbot-master98.srv.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::mozilla {
        "bm98-tests1-tegra":
            http_port => 8201,
            master_type => "tests",
            basedir => "tests1-tegra";
    }
    include toplevel::server::buildmaster
}

# temporary node defs for vcssync hosts
node /vcssync[1-2].srv.releng.usw2.mozilla.com/ {
    include toplevel::server
}

# Package Builders

node "ubuntu64packager1.srv.releng.use1.mozilla.com" {
    include toplevel::server::pkgbuilder
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
