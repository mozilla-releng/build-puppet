# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Support for dashes in class and defined type names differs depending on the release of Puppet you’re running. 
# To ensure compatibility on all versions, you should avoid using dashes.
class buildduty_tools::builddutytools {
    include ::config
    include users::buildduty
    include packages::mozilla::python27
    include packages::mozilla::py27_mercurial
    include packages::libffi

    python::virtualenv {
        '/home/buildduty/buildduty-tools':
            python          => $::packages::mozilla::python27::python,
            rebuild_trigger => Class['packages::mozilla::python27'],
            require         => [
                Class['packages::mozilla::python27'],
            ],
            user            => $users::buildduty::username,
            group           => $users::buildduty::group,
            packages        => file("buildduty_tools/requirements.txt");
    }

    file {
        '/home/buildduty/buildduty-tools/repos':
            ensure  => directory,
            owner   => $users::buildduty::username,
            group   => $users::buildduty::group,
            require => [
                Python::Virtualenv['/home/buildduty/buildduty-tools'],
            ];
    }

    mercurial::repo {
        'buildbot-clone':
            hg_repo => 'https://hg.mozilla.org/build/buildbot',
            dst_dir => '/home/buildduty/buildduty-tools/repos/buildbot',
            user    => $users::buildduty::username,
            branch  => 'production-0.8',
            require => [
                File['/home/buildduty/buildduty-tools/repos'],
            ];
        'buildbotcustom-clone':
            hg_repo => 'https://hg.mozilla.org/build/buildbotcustom',
            dst_dir => '/home/buildduty/buildduty-tools/repos/buildbotcustom',
            user    => $users::buildduty::username,
            branch  => 'production-0.8',
            require => [
                File['/home/buildduty/buildduty-tools/repos'],
            ];
        'configs-clone':
            hg_repo => 'https://hg.mozilla.org/build/buildbot-configs',
            dst_dir => '/home/buildduty/buildduty-tools/repos/buildbot-configs',
            user    => $users::buildduty::username,
            branch  => 'production',
            require => [
                File['/home/buildduty/buildduty-tools/repos'],
            ];
        'braindump-clone':
            hg_repo => 'https://hg.mozilla.org/build/braindump',
            dst_dir => '/home/buildduty/buildduty-tools/repos/braindump',
            user    => $users::buildduty::username,
            branch  => 'default',
            require => [
                File['/home/buildduty/buildduty-tools/repos'],
            ];
        'tools-clone':
            hg_repo => 'https://hg.mozilla.org/build/tools',
            dst_dir => '/home/buildduty/buildduty-tools/repos/tools',
            user    => $users::buildduty::username,
            branch  => 'default',
            require => [
                File['/home/buildduty/buildduty-tools/repos'],
            ];
    }
}
