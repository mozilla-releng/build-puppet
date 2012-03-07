node "relabs-buildbot-master.build.mtv1.mozilla.com" {
    include toplevel::server
}

node "dl120g7-r4-4844.build.scl1.mozilla.com" {
    include toplevel::slave::build
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

