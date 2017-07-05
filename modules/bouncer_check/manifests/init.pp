# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class bouncer_check {
    include packages::mozilla::python27
    include dirs::tools
    $venv_root = '/tools/nagios-tools'

    python::virtualenv {
        $venv_root:
            python   => $packages::mozilla::python27::python,
            require  => Class['packages::mozilla::python27'],
            packages => [
                'argparse==1.2.1',
                'nagios-tools==0.5',
                'nagiosplugin==1.1',
                'wsgiref==0.1.2',
            ];
    }
    nrpe::check {
        'check_bouncer':
            cfg     => "${venv_root}/bin/check_bouncer",
            require => Python::Virtualenv[$venv_root];
    }
}
