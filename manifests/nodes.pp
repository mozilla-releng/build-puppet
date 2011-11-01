node "relabs-buildbot-master.build.mtv1.mozilla.com" {
    include toplevel::server;
}

node "relabs-slave.build.mtv1.mozilla.com" {
    include toplevel::slave;
}

