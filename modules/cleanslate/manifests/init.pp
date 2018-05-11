# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
class cleanslate {
    include dirs::opt
    include cleanslate::settings
    include packages::mozilla::python27
    $tmp_cleanstate =  $::operatingsystem ? {
        windows => 'C:\etc\cleanstate',
        default => '/var/tmp/cleanslate'
    }
    file {
        $tmp_cleanstate:
            # old cleanslate files shouldn't persist between reboots
            ensure => absent;
    }

    python::virtualenv {
        $cleanslate::settings::root:
            python          => $packages::mozilla::python27::python,
            rebuild_trigger => Class['packages::mozilla::python27'],
            require         => Class['packages::mozilla::python27'],
            packages        => file("cleanslate/requirements.txt");
    }

}
