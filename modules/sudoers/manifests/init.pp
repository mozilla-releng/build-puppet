# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class sudoers {
    include sudoers::settings

    if $::operatingsystem != 'Windows' {
        # TODO-WIN: this should be replaced with an equivalent on windows
        include packages::sudo
        concat {
            '/etc/sudoers' :
                require => Class['packages::sudo'],
                mode    => $sudoers::settings::mode,
                owner   => $sudoers::settings::owner,
                group   => $sudoers::settings::group,
        }
        concat::fragment {
            '00-base':
                target  => '/etc/sudoers',
                content => template("${module_name}/sudoers-base.erb");
        }

        file {
            '/etc/sudoers.d' :
                ensure => absent,
                force  => true;
        }
    }
}
