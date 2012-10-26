node /bld-centos6-hp-\d+.build.scl1.mozilla.com/ {
    include toplevel::slave::build::mock
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

node /.*\.build\.aws-.*\.mozilla\.com/ {
    # Make sure we get our /etc/hosts set up
    class {
        "network::aws": stage => network,
    }
    include toplevel::slave::build::mock
}

node /puppetmaster-\d+\..*\.aws-.*\.mozilla\.com/ {
    include toplevel::server::puppetmaster::standalone
}

node "mobile-services.build.scl1.mozilla.com" {
     $is_bmm_admin_host = 0
     include toplevel::server::bmm
}

node /mobile-imaging-\d+\.p\d+\.releng\.scl1\.mozilla\.com/ {
     $is_bmm_admin_host = $fqdn ? { /^mobile-imaging-001/ => 1, default => 0 }
     include toplevel::server::bmm
}
