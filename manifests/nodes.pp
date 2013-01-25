# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
node /bld-centos6-hp-\d+.build.scl1.mozilla.com/ {
    include toplevel::slave::build::mock
}

node "relabs02.build.mtv1.mozilla.com" {
}

node "relabs06.build.mtv1.mozilla.com" {
    include toplevel::server::puppetmaster::standalone
}

node "relabs07.build.mtv1.mozilla.com" {
}

node "relabs08.build.mtv1.mozilla.com" {
    include toplevel::slave::build::mock
}

node "relabs-buildbot-master.build.mtv1.mozilla.com" {
    include toplevel::server
}

node "relabs-slave.build.mtv1.mozilla.com" {
    include toplevel::slave::test
}

node /foopy\d+.build.mtv1.mozilla.com/ {
    include toplevel::server::foopy
}

node /foopy\d+.build.scl1.mozilla.com/ {
    include toplevel::server::foopy
}

node /foopy\d+.p\d+.releng.scl1.mozilla.com/ {
    include toplevel::server::foopy
}

node "linux-foopy-test.build.mtv1.mozilla.com" {
    include toplevel::server::foopy
}

node /talos-mtnlion-r5-\d+.test.releng.scl3.mozilla.com/ {
    include toplevel::slave::test
}

node /seamicro-test\d+.build.releng.scl3.mozilla.com/ {
    include toplevel::slave::build::mock
}

node /seamicro-test\d+.try.releng.scl3.mozilla.com/ {
    include toplevel::slave::build::mock
}

node /(bld|try|dev)-.*\.build\.aws-.*\.mozilla\.com/ {
    # Make sure we get our /etc/hosts set up
    class {
        "network::aws": stage => network,
    }
    include toplevel::slave::build::mock
}

node /puppetmaster-\d+\..*\.aws-.*\.mozilla\.com/ {
    include toplevel::server::puppetmaster::standalone
}

node "mobile-imaging-stage1.build.scl1.mozilla.com" {
    $extra_root_keys = [ 'mcote' ]
    $is_bmm_admin_host = true
    $mozpool_staging = true
    include toplevel::server::mozpool
}

node /mobile-imaging-\d+\.p\d+\.releng\.scl1\.mozilla\.com/ {
    $extra_root_keys = [ 'mcote' ]
    $is_bmm_admin_host = $fqdn ? { /^mobile-imaging-001/ => true, default => false }
    $mozpool_staging = false
    include toplevel::server::mozpool
}

node /tst-.*\.build\.aws-.*\.mozilla\.com/ {
    # Make sure we get our /etc/hosts set up
    class {
        "network::aws": stage => network,
    }
    include toplevel::slave::test
}

node "dustin-ubuntu.srv.releng.scl3.mozilla.com" {
    include toplevel::slave::test
}
