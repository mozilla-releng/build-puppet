# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class collectd::plugins::generic( $plugins ) {
    include collectd
    include collectd::settings

    # generic plugins do not require module specific arguments

    collectd::util::config_gen { $plugins: arg_array => undef }
}
