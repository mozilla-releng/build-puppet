# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class smarthost {
    anchor {
        'smarthost::begin': ;
        'smarthost::end': ;
    }
    Anchor['smarthost::begin'] ->
    class {
        'smarthost::install': ;
    } -> Anchor['smarthost::end']

    Anchor['smarthost::begin'] ->
    class {
        'smarthost::setup': ;
    } -> Anchor['smarthost::end']

    Anchor['smarthost::begin'] ->
    class {
        'smarthost::daemon': ;
    } -> Anchor['smarthost::end']
}
