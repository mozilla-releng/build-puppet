# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

## builders

node /servo-.*\.build\.servo\.aws-.*\.mozilla\.com/ {
    # Make sure we get our /etc/hosts set up
    class {
        "network::aws": stage => network,
    }
    include toplevel::slave::build::mock
}

node /servo-.*\.build\.servo\.releng\.(use1|usw2)\.mozilla.com/ {
    # Make sure we get our /etc/hosts set up
    class {
        "network::aws": stage => network,
    }
    include toplevel::slave::build::mock
}


## puppetmasters

node /puppetmaster-\d+\..*\.aws-.*\.mozilla\.com/ {
    include toplevel::server::puppetmaster::standalone
}


## buildbot masters

node "buildbot-master-servo1.srv.servo.releng.use1.mozilla.com" {
    buildmaster::buildbot_master::servo {
        "bms1-servo1":
            http_port => 8001,
            basedir => "servo1";
    }
    include toplevel::server::bors::servo
}
