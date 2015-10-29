# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class nightlypromotion::settings {
    include ::config

    $root = $config::nightlypromotion_root
    $script = "${root}/nightly_promotion.py"
    $logfile = "${root}/nightly-promotion.log"
    $cachefile = "${root}/cache.json"
    $authfile = "${buildmaster::settings::master_root}/build1/master/BuildSlaves.py"
    $cacert = "${buildmaster::settings::master_root}/build1/tools/misc/certs/ca-bundle.crt"
}
