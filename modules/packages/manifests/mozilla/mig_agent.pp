# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mozilla::mig_agent {
    anchor {
        'packages::mozilla::mig_agent::begin': ;
        'packages::mozilla::mig_agent::end': ;
    }

    # The mig-agent package does not start the agent automatically on install.
    # The agent needs to be invoked manually after install, by calling '/sbin/mig-agent'.
    # service files for (upstart|systemd|sysvinit) are created by the agent itself.
    # see doc at https://github.com/mozilla/mig/blob/master/doc/concepts.rst
    case $::operatingsystem {
        'CentOS', 'RedHat': {
            realize(Packages::Yumrepo['mig-agent'])
            Anchor['packages::mozilla::mig_agent::begin'] ->
            package {
                'mig-agent':
                    ensure => '20160729_0.a06734a.prod-1'
            } -> Anchor['packages::mozilla::mig_agent::end']
        }
        'Ubuntu': {
            realize(Packages::Aptrepo['mig-agent'])
            Anchor['packages::mozilla::mig_agent::begin'] ->
            package {
                'mig-agent':
                    ensure => '20160729-0.a06734a.prod'
            } -> Anchor['packages::mozilla::mig_agent::end']
        }
        'Darwin': {
            Anchor['packages::mozilla::mig_agent::begin'] ->
            packages::pkgdmg {
                'mig-agent':
                    version             => '20160729-0.a06734a.prod-x86_64',
                    os_version_specific => false;
            } -> Anchor['packages::mozilla::mig_agent::end']
        }
        default: {
            fail("mig is not supported on ${::operatingsystem}")
        }
    }
}
