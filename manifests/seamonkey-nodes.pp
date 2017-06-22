# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

## puppetmasters

node 'sea-puppet.community.scl3.mozilla.com' {
    include toplevel::server::puppetmaster
}

## buildbot masters

node 'sea-master1.community.scl3.mozilla.com' {
    buildmaster::buildbot_master::mozilla {
        'bm01-universal':
            http_port   => 8010,
            master_type => 'build',
            basedir     => 'master01';
    }
    include toplevel::server::buildmaster::seamonkey
}

## Builders

node /sea-hp-linux64-(\d+).community.scl3.mozilla.com/ {
    $slave_trustlevel = 'core'
    include toplevel::slave::releng::build::mock
}
