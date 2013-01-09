# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mozpool::httpd {
    httpd::config {
        "mozpool_httpd.conf" :
            contents => template("mozpool/mozpool_httpd_conf.erb");
    }
}
