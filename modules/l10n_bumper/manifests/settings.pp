# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class l10n_bumper::settings {
    include ::config

    $root       = '/builds/l10n-bumper'
    $mailto     = 'aki@mozilla.com'
    $share_base = '/builds/hg-shared'
}
