# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# (private)
#
# Ensure that this module's misc directory exists
class python27::misc_python_dir {
    include python27::virtualenv::settings
    if ($::operatingsystem != Windows) {
        include dirs::tools # assuming this dir is under /tools
    }
    file {
        $python27::virtualenv::settings::misc_python_dir:
            ensure => directory;
    }
}
