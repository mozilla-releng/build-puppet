# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class security {

    # including this class just gets you $security::level, which corresponds to
    # the host's system security level, as defined in
    # https://mana.mozilla.org/wiki/display/ITSECURITY/IT+System+security+guidelines
    # Other modules then alter their configurations depending on the host's security level.
    #
    # The available levels are "low", "medium", "high", and "maximum". Default is "medium".

    if (has_aspect('low-security')) {
        $level = 'low'
    }
    elsif (has_aspect('high-security')) {
        $level = 'high'
    }
    elsif (has_aspect('maximum-security')) {
        $level = 'maximum'
    }
    else {
        $level = 'medium'
    }

    # the following booleans can help determine if a host is at the given level
    # or above.
    case $level {
        low: {
            $low     = true
            $medium  = false
            $high    = false
            $maximum = false
        }
        medium: {
            $low     = true
            $medium  = true
            $high    = false
            $maximum = false
        }
        high: {
            $low     = true
            $medium  = true
            $high    = true
            $maximum = false
        }
        maximum: {
            $low     = true
            $medium  = true
            $high    = true
            $maximum = true
        }
    }
}
