# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class cruncher::reportor {
    include ::config
    include users::buildduty
    include packages::mozilla::python27
    include packages::mozilla::py27_mercurial
    include packages::mozilla::git
    include packages::libffi

    git::repo {
        'reportor-clone':
            repo    => 'https://github.com/catlee/reportor.git',
            dst_dir => '/home/buildduty/reportor',
            user    => $users::buildduty::username,
            require => [
                Class['packages::mozilla::git'],
            ];
    }

    python::virtualenv {
        '/home/buildduty/reportor':
            python   => $::packages::mozilla::python27::python,
            require  => [
                Class['packages::mozilla::python27'],
                Git::Repo['reportor-clone'],
            ],
            user     => $users::buildduty::username,
            group    => $users::buildduty::group,
            packages => [
                # Pinning to avoid investigating if an update would break
                # https://bugzilla.mozilla.org/show_bug.cgi?id=1289822#c7
                'requests==2.8.1',
                'SQLAlchemy',
                'simplejson',
                'MySQL-python',
            ];
    }

    exec {
        'reportor-setup':
            name      => '/home/buildduty/reportor/bin/python setup.py install --prefix=/home/buildduty/reportor',
            cwd       => '/home/buildduty/reportor',
            user      => $users::buildduty::username,
            logoutput => on_failure,
            require   => [
                Python::Virtualenv['/home/buildduty/reportor'],
                Git::Repo['reportor-clone'],
                Class['packages::libffi'],
            ],
            creates   => '/home/build/reportor/bin/reportor';
    }

    file {
        '/home/buildduty/reportor/bin/reportor.sh':
            content => template('cruncher/reportor.sh.erb'),
            owner   => $users::buildduty::username,
            group   => $users::buildduty::group,
            mode    => '0755',
            require => [
                Exec['reportor-setup'],
            ];
        '/home/buildduty/reportor/reports/credentials.ini':
            content => template('cruncher/reportor_credentials.ini.erb'),
            owner   => $users::buildduty::username,
            group   => $users::buildduty::group,
            mode    => '0600',
            require => [
                Exec['reportor-setup'],
            ];
    }
}
