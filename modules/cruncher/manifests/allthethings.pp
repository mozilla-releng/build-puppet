# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class cruncher::allthethings {
    include ::config
    include users::buildduty
    include packages::mozilla::python27
    include packages::mozilla::py27_mercurial
    include packages::libffi

    python::virtualenv {
        '/home/buildduty/allthethings':
            python   => $::packages::mozilla::python27::python,
            require  => [
                Class['packages::mozilla::python27'],
            ],
            user     => $users::buildduty::username,
            group    => $users::buildduty::group,
            packages => [
                'Jinja2==2.7.1',
                'MarkupSafe==0.18',
                'Twisted==10.2.0',
                'argparse==1.2.1',
                'cffi==1.3.0',
                'cryptography==0.6',
                'pyOpenSSL==0.10',
                'pyasn1==0.1.9',
                'pycparser==2.13',
                'pycrypto==2.6',
                'simplejson==3.3.0',
                'six==1.9.0',
                'wsgiref==0.1.2',
                'zope.interface==4.0.2',
            ];
    }

    file {
        '/home/buildduty/allthethings/repos':
            ensure  => directory,
            owner   => $users::buildduty::username,
            group   => $users::buildduty::group,
            require => [
                Python::Virtualenv['/home/buildduty/allthethings'],
            ];
    }

    mercurial::repo {
        'allthethings-buildbot-clone':
            hg_repo => 'https://hg.mozilla.org/build/buildbot',
            dst_dir => '/home/buildduty/allthethings/repos/buildbot',
            user    => $users::buildduty::username,
            branch  => 'production-0.8',
            require => [
                File['/home/buildduty/allthethings/repos'],
            ];
        'allthethings-buildbotcustom-clone':
            hg_repo => 'https://hg.mozilla.org/build/buildbotcustom',
            dst_dir => '/home/buildduty/allthethings/repos/buildbotcustom',
            user    => $users::buildduty::username,
            branch  => 'production-0.8',
            require => [
                File['/home/buildduty/allthethings/repos'],
            ];
        'allthethings-configs-clone':
            hg_repo => 'https://hg.mozilla.org/build/buildbot-configs',
            dst_dir => '/home/buildduty/allthethings/repos/buildbot-configs',
            user    => $users::buildduty::username,
            branch  => 'production',
            require => [
                File['/home/buildduty/allthethings/repos'],
            ];
        'allthethings-braindump-clone':
            hg_repo => 'https://hg.mozilla.org/build/braindump',
            dst_dir => '/home/buildduty/allthethings/repos/braindump',
            user    => $users::buildduty::username,
            branch  => 'default',
            require => [
                File['/home/buildduty/allthethings/repos'],
            ];
        'allthethings-tools-clone':
            hg_repo => 'https://hg.mozilla.org/build/tools',
            dst_dir => '/home/buildduty/allthethings/repos/tools',
            user    => $users::buildduty::username,
            branch  => 'default',
            require => [
                File['/home/buildduty/allthethings/repos'],
            ];
    }

    exec {
        'allthethings-pip-install-master':
            name      => '/home/buildduty/allthethings/bin/pip install -e .',
            cwd       => '/home/buildduty/allthethings/repos/buildbot/master',
            user      => $users::buildduty::username,
            logoutput => on_failure,
            require   => [
                Mercurial::Repo['allthethings-buildbot-clone'],
            ];
        'allthethings-pip-install-slave':
            name      => '/home/buildduty/allthethings/bin/pip install buildbot-slave==0.8.4-pre-moz2',
            cwd       => '/home/buildduty/allthethings',
            user      => $users::buildduty::username,
            logoutput => on_failure,
            require   => [
                Exec['allthethings-pip-install-master'],
            ];
        'allthethings-pythonpath1':
            name      => '/bin/echo /home/buildduty/allthethings/repos >> /home/buildduty/allthethings/lib/python2.7/site-packages/releng.pth',
            cwd       => '/home/buildduty/allthethings',
            user      => $users::buildduty::username,
            logoutput => on_failure,
            require   => [
                File['/home/buildduty/allthethings/repos'],
            ];
        'allthethings-pythonpath2':
            name      => '/bin/echo /home/buildduty/allthethings/repos/tools/lib/python >> /home/buildduty/allthethings/lib/python2.7/site-packages/releng.pth',
            cwd       => '/home/buildduty/allthethings',
            user      => $users::buildduty::username,
            logoutput => on_failure,
            require   => [
                Mercurial::Repo['allthethings-tools-clone'],
            ];
    }
}
