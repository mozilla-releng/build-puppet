# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

node "vagrant-ubuntu-trusty-64.fritz.box" {
    include toplevel::slave::qa::mozmill_ci
}

# Temporary nodes for testing puppetagain on QA infrastructure

node "mm-ub-1204-32-temp.qa.scl3.mozilla.com" {
    include toplevel::slave::qa::mozmill_ci
}

node "qa-deploystudio1.qa.scl3.mozilla.com" {
    include toplevel::slave::qa::mozmill_ci
}


### Servers ###

node "db1.qa.scl3.mozilla.com" {
    include toplevel::server
}

node "puppetmaster1.qa.scl3.mozilla.com" {
    include toplevel::server::puppetmaster
}


### Mozmill-CI staging

node "mm-ci-staging.qa.scl3.mozilla.com" {
    include toplevel::server::mozmill_ci
}

node /^mm-osx-\d+\.qa\.scl3\.mozilla\.com$/ {
    include toplevel::slave::qa::mozmill_ci
}

node /^mm-ub-\d+-\d+\.qa\.scl3\.mozilla\.com$/ {
    include toplevel::slave::qa::mozmill_ci
}

node /^mm-win-\w+-\d+\.qa\.scl3\.mozilla\.com$/ {
    include toplevel::slave::qa::mozmill_ci
}

### Mozmill-CI production

node "mm-ci-master.qa.scl3.mozilla.com" {
    include toplevel::server::mozmill_ci
}

node /^mm-osx-\d+-\d\.qa\.scl3\.mozilla\.com$/ {
    include toplevel::slave::qa::mozmill_ci
}

node /^mm-ub-\d+-\d+-\d+\.qa\.scl3\.mozilla\.com$/ {
    include toplevel::slave::qa::mozmill_ci
}

node /^mm-win-\w+-\d+-\d+\.qa\.scl3\.mozilla\.com$/ {
    include toplevel::slave::qa::mozmill_ci
}
