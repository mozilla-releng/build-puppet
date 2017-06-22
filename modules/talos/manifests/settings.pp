# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Define common talos variables

class talos::settings {
    # public variables used by talos module
    $apachedocumentroot = $::operatingsystem ? {
        Windows => 'C:\slave\talos-data\talos',
        default => '/builds/slave/talos-data/talos'
    }
    # This is required to allow talos tests to run on 10.10
    $requireall =  $::macosx_productversion_major ? {
        10.10   => 'Require all granted',
        default => ''
    }
}
