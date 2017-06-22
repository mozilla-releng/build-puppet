# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class shellprofile::base {
    include shellprofile::settings
    include users::root

    file {
        $::shellprofile::settings::profile_d:
            ensure => directory,
            owner  => $users::root::username,
            group  => $users::root::group;
        $::shellprofile::settings::profile_puppet_d:
            ensure  => directory,
            owner   => $users::root::username,
            group   => $users::root::group,
            purge   => true,
            recurse => true,
            force   => true;
        "${::shellprofile::settings::profile_d}/puppetdir.sh":
            owner   => $users::root::username,
            group   => $users::root::group,
            mode    => '0755',
            content => template('shellprofile/puppetdir.sh.erb');
    }

    case ($::operatingsystem) {
        CentOS: {
            # profile.d actually works out of the box
        }
        Ubuntu: {
            # ~root/.bashrc is patched in users::root::setup
        }
        Darwin: {
            file {
                # patch /etc/profile to run /etc/profile.d/*.sh
                '/etc/profile':
                    source => 'puppet:///modules/shellprofile/darwin-profile';
            }
        }
        Windows: {
            # TODO: add support for profile.d on Windows
        }
        default: {
            fail("Don't know how to setup profile.d on this operating system")
        }
    }
}
