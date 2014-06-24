# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# a task to be run by runner
define runner::task($content=undef, $source=undef) {
    include runner::settings
    file {
        "${runner::settings::taskdir}/${title}":
            before  => Service['runner'],
            content => $content,
            source  => $source,
            mode    => '0755';
    }
}
