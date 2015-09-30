# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class toplevel::slave::releng::build::mock::av inherits toplevel::slave::releng::build::mock {
    include clamav::daemon
    include clamav::freshclam
    include packages::p7zip
}
