# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# We use config rather than settings because "settings" is a magic class
class config inherits config::base {
    $org = "seamonkey"

    $puppet_notif_email = "Callek@gmail.com"
    $builder_username = "seabld"
}
