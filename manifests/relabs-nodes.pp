# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

## relabs machines - check with dustin to borrow one

node "relabs-puppet1.relabs.releng.scl3.mozilla.com" {
    include toplevel::server::puppetmaster
}

node "cloudstack1.relabs.releng.scl3.mozilla.com" {
    # dustin is using this to run cloudstack
    include toplevel::server
}

node "hp1.relabs.releng.scl3.mozilla.com" {
    # dustin is using this to run HVM for cloudstack
    include toplevel::server
}

node "hp2.relabs.releng.scl3.mozilla.com" {
}

node "hp3.relabs.releng.scl3.mozilla.com" {
}

node "hp4.relabs.releng.scl3.mozilla.com" {
}

node "hp5.relabs.releng.scl3.mozilla.com" {
}

node "hp6.relabs.releng.scl3.mozilla.com" {
}

node "ix-mn-1.relabs.releng.scl3.mozilla.com" {
}

node "ix-mn-2.relabs.releng.scl3.mozilla.com" {
}

node "ix-mn-3.relabs.releng.scl3.mozilla.com" {
}

node "ix-mn-4.relabs.releng.scl3.mozilla.com" {
}

node "ix-mn-5.relabs.releng.scl3.mozilla.com" {
}

node "ix-mn-6.relabs.releng.scl3.mozilla.com" {
}

node "ix1204-1.relabs.releng.scl3.mozilla.com" {
}

node "ix1204-2.relabs.releng.scl3.mozilla.com" {
}

node "ix1204-3.relabs.releng.scl3.mozilla.com" {
}

node "ix1204-4.relabs.releng.scl3.mozilla.com" {
}
