# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# this class configures yum to our liking
class packages::yum_config {
    # turn off fastestmirror
    file {
        '/etc/yum/pluginconf.d/fastestmirror.conf':
            content => "[main]\nenabled=0\n";
    }
}
