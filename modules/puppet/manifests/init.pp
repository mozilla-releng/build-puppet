# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Upgrade and configure puppet.  Note that the puppet startup is deferred to
# puppet::atboot and puppet::periodic; the former is used for slaves, while
# other systems run the latter.
class puppet {
    include packages::puppet
    include puppet::config
    include puppet::motd
    include puppet::cleanup
}
