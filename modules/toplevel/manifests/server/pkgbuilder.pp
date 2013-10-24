# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# These are machines that connect to our mobile testers and act as build slaves
# However these do not reboot frequently, and typically handle multiple
# buildbot instances at once.

class toplevel::server::pkgbuilder inherits toplevel::server {
    include ::pkgbuilder
}

