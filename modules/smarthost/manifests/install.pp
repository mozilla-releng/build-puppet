# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class smarthost::install {
    anchor {
        'smarthost::install::begin': ;
        'smarthost::install::end': ;
    }

    Anchor['smarthost::install::begin'] ->
    class {
        'packages::postfix': ;
    } -> Anchor['smarthost::install::end']

    Anchor['smarthost::install::begin'] ->
    class {
        'packages::mailx': ;
    } -> Anchor['smarthost::install::end']
}
