# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Setup extlookup which we only use for config magic
$extlookup_datadir = "$settings::manifestdir/extlookup"
$extlookup_precedence = ["local-config", "default-config", "secrets", "secrets-template"]

# basic top-level classes with basic settings
import "stages.pp"
import "nodes.pp"

# Default to root:root 0644 ownership
File {
    owner => 0,
    group => 0,
    mode => "0644",
    backup => false,
}
