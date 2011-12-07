node "relabs-buildbot-master.build.mtv1.mozilla.com" {
    include toplevel::server
}

node "relabs08.build.mtv1.mozilla.com" {
    include toplevel::slave
}

node "relabs-slave.build.mtv1.mozilla.com" {
    include toplevel::slave
}

