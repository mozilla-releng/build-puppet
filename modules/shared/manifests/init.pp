# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class shared {
    # the appropriate /usr subdir for libraries; this is only useful
    # on linux platforms.
    $lib_arch_dir = $::hardwaremodel ? {
        i686    => 'lib',
        x86_64  => 'lib64',
        default => 'lib'
    }
}
