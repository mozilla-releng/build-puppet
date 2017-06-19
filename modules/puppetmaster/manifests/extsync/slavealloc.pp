# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class puppetmaster::extsync::slavealloc($ensure, $slavealloc_api_url) {
    include packages::pyyaml
    puppetmaster::extsync_crontask {
        'slavealloc':
            ensure            => $ensure,
            minute            => '*/10',
            generation_script => template("${module_name}/extsync/slavealloc.erb");
    }
}
