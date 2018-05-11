# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class bouncer_check {
    include packages::mozilla::python27
    include dirs::tools
    $venv_root = '/tools/nagios-tools'

    python::virtualenv {
        $venv_root:
            python          => $packages::mozilla::python27::python,
            rebuild_trigger => Class['packages::mozilla::python27'],
            require         => Class['packages::mozilla::python27'],
            packages        => file("bouncer_check/requirements.txt");
    }
    nrpe::check {
        'check_bouncer':
            cfg     => "${venv_root}/bin/check_bouncer",
            require => Python::Virtualenv[$venv_root];
    }
}
