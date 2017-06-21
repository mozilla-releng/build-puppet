# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mozilla::dumbwin32proc {

    include  buildslave::install

    file {
        'C:/mozilla-build/buildbotve/Lib/site-packages/twisted/internet/_dumbwin32proc.py':
            source  => 'puppet:///modules/packages/_dumbwin32proc.py',
            require => Class['buildslave::install'];
    }
}
