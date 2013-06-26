# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

## relabs machines - check with dustin to borrow one

node "relabs02.build.mtv1.mozilla.com" {
    include toplevel::server
}

node "relabs03.build.mtv1.mozilla.com" {
    # distinguished master for the relabs puppet cluster
    include toplevel::server::puppetmaster
}

node "relabs04.build.mtv1.mozilla.com" {
    # temporary non-distinguished master
    include toplevel::server::puppetmaster
}

node "relabs05.build.mtv1.mozilla.com" {
    include toplevel::server
}

node "relabs06.build.mtv1.mozilla.com" {
}

node "relabs07.build.mtv1.mozilla.com" {
}

node "relabs08.build.mtv1.mozilla.com" {
}
