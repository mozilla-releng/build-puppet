node "relabs-buildbot-master.build.mtv1.mozilla.com" {
    include toplevel::server
}

node "relabs07.build.mtv1.mozilla.com" {
    include toplevel::slave::build
}

node "relabs08.build.mtv1.mozilla.com" {
    include toplevel::slave::build
}

node "relabs-slave.build.mtv1.mozilla.com" {
    include toplevel::slave::test
}

