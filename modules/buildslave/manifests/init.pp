# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# This module is responsible for installing and running buildbot-slave on all
# slaves.  Do not be confused by the name 'buildslave' - this applies to all
# slaves used in releng -- build, test, whatever.

class buildslave {
    anchor {
        'buildslave::begin': ;
        'buildslave::end': ;
    }

    Anchor['buildslave::begin'] ->
    class {
        'buildslave::install': ;
    } -> Anchor['buildslave::end']

    Anchor['buildslave::begin'] ->
    class {
        'buildslave::startup': ;
    } -> Anchor['buildslave::end']
}
