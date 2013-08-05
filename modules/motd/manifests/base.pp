# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class motd::base {
    include concat::setup

    $group = $::operatingsystem ? {
        Darwin => wheel,
        default => root
    }
    concat {
        "/etc/motd":
            owner => root,
            group => $group,
            mode => 0644;
    }
    # need at least one fragment, or concat will fail:
    concat::fragment {
        empty-motd:
            target => "/etc/motd",
            content => ""
    }
}
