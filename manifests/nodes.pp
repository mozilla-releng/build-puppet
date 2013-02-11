# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

## relabs machines - check with dustin to borrow one

node "relabs02.build.mtv1.mozilla.com" {
}

node "relabs03.build.mtv1.mozilla.com" {
}

node "relabs04.build.mtv1.mozilla.com" {
}

node "relabs05.build.mtv1.mozilla.com" {
}

node "relabs06.build.mtv1.mozilla.com" {
}

node "relabs07.build.mtv1.mozilla.com" {
}

node "relabs08.build.mtv1.mozilla.com" {
}

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

node /talos-mtnlion-r5-\d+.test.releng.scl3.mozilla.com/ {
    include toplevel::slave::test
}

node /tst-.*\.build\.aws-.*\.mozilla\.com/ {
    # Make sure we get our /etc/hosts set up
    class {
        "network::aws": stage => network,
    }
    include toplevel::slave::test
}

node "ix-mn-linux64-001.test.releng.scl3.mozilla.com" {
}

node "ix-mn-linux64-002.test.releng.scl3.mozilla.com" {
}

node "talos-linux32-ix-001.test.releng.scl3.mozilla.com" {
    include toplevel::slave
}

node "talos-linux32-ix-001.test.releng.scl3.mozilla.com" {
    include toplevel::slave
}

## builders

node /linux64-ix-slave\d+.build.scl1.mozilla.com/ {
    include toplevel::slave::build::mock
}

node /bld-centos6-hp-\d+.build.scl1.mozilla.com/ {
    include toplevel::slave::build::mock
}

node /(bld|try|dev)-.*\.build\.aws-.*\.mozilla\.com/ {
    # Make sure we get our /etc/hosts set up
    class {
        "network::aws": stage => network,
    }
    include toplevel::slave::build::mock
}

## puppetmasters

node /puppetmaster-\d+\..*\.aws-.*\.mozilla\.com/ {
    include toplevel::server::puppetmaster::standalone
}

## mozpool servers

node "mobile-imaging-stage1.p127.releng.scl1.mozilla.com" {
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

