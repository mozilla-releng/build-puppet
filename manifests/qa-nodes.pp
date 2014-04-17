# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

node "puppetmaster1.qa.scl3.mozilla.com" {
    include toplevel::server::puppetmaster
}

node "mm-ub-1204-32-temp.qa.scl3.mozilla.com" {
    include toplevel::base
}

node "mm-osx-106.qa.scl3.mozilla.com" {
    include toplevel::base
}

node "mm-osx-107.qa.scl3.mozilla.com" {
    include toplevel::base
}

node "mm-osx-108.qa.scl3.mozilla.com" {
    include toplevel::base
}

node "mm-osx-109.qa.scl3.mozilla.com" {
    include toplevel::base
}

node "mm-ub-1204-32.qa.scl3.mozilla.com" {
    include toplevel::base
}

node "mm-ub-1204-64.qa.scl3.mozilla.com" {
    include toplevel::base
}

node "mm-ub-1310-32.qa.scl3.mozilla.com" {
    include toplevel::base
}

node "mm-ub-1310-64.qa.scl3.mozilla.com" {
    include toplevel::base
}

node "mm-win-xp-32.qa.scl3.mozilla.com" {
    include toplevel::base
}

node "mm-win-7-32.qa.scl3.mozilla.com" {
    include toplevel::base
}

node "mm-win-7-64.qa.scl3.mozilla.com" {
    include toplevel::base
}

node "mm-win-81-32.qa.scl3.mozilla.com" {
    include toplevel::base
}

node "mm-win-81-64.qa.scl3.mozilla.com" {
    include toplevel::base
}
