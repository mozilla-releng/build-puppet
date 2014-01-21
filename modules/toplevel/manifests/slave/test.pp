# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class toplevel::slave::test inherits toplevel::slave {
    include talos
    include vnc
    include users::builder::autologin
    include packages::fonts
    include tweaks::fonts
    include tweaks::cleanup
    class {
        'slave_secrets':
            slave_type => 'test';
    }
}
