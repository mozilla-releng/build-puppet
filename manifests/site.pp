# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

import "stages.pp"
import "extlookup.pp"
# both of these should be symlnks to the appropriate organization
import "config.pp"
import "nodes.pp"

# Default to root:root 0644 ownership
File {
    owner => 0,
    group => 0,
    mode => "0644",
    backup => false,
}
