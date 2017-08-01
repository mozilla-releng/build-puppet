# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class funsize_scheduler {
    include ::config
    include funsize_scheduler::services
    include funsize_scheduler::settings
    include dirs::builds
    include packages::gcc
    include packages::libffi
    include packages::make
    include packages::mozilla::python27
    include users::builder

    python::virtualenv {
        $funsize_scheduler::settings::root:
            python   => $packages::mozilla::python27::python,
            require  => [
                Class['packages::mozilla::python27'],
                Class['packages::libffi'],
            ],
            user     => $users::builder::username,
            group    => $users::builder::group,
            packages => [
                'amqp==1.4.6',
                'anyjson==0.3.3',
                'argparse==1.4.0',
                'cffi==1.9.1',
                'cryptography==1.7.1',
                'ecdsa==0.10',
                'enum34==1.0.4',
                'funsize==0.92',
                'ndg_httpsclient==0.4.2',
                'idna==2.2',
                'importlib==1.0.4',
                'iniparse==0.3.1',
                'ipaddress==1.0.18',
                'Jinja2==2.7.1',
                'kombu==3.0.26',
                'MarkupSafe==0.23',
                'more_itertools==2.2',
                # Actual package is PGPy 0.4.0.post1, but older `pip`s have issues with the name
                'PGPy==0.4.0',
                'PyHawk-with-a-single-extra-commit==0.1.5',
                'pyOpenSSL==16.2.0',
                'PyYAML==3.10',
                'pyasn1==0.1.9',
                'pycparser==2.13',
                'pycrypto==2.6.1',
                'python-jose==0.5.6',
                'redo==1.4.1',
                # Taskcluster pins requests 2.4.3, so we need to de the same,
                # even though we'd rather use a more up-to-date version.
                'requests[security]==2.4.3',
                'setuptools==33.1.1',
                'singledispatch==3.4.0.3',
                'six==1.10.0',
                'slugid==1.0.6',
                'taskcluster>=0.0.26',
                'wsgiref==0.1.2',
            ];
    }
}
