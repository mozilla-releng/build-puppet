# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# toplevel class for running a standalone puppet master
class toplevel::server::puppetmaster::standalone inherits toplevel::server::puppetmaster {
    include ::puppetmaster::standalone

    # standalone puppetmasters update with 'puppet apply', so don't run puppet agen 
    Class['puppet'] {
        type => 'none'
    }
}
