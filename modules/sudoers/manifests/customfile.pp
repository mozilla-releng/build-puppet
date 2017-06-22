# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define sudoers::customfile($content) {
    include sudoers

    #In Windows this is handled by GPO
    if $::operatingsystem != 'Windows' {
        concat::fragment {
            "10-${title}":
                target  => '/etc/sudoers',
                content => $content;
        }
    }
}
