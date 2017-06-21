# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::gnupg {
    case $::operatingsystem {
        CentOS: {
            package {
                'gnupg2':
                    ensure => latest;
            }
        }

        Darwin: {
            # This is from old Python, but is just an old version of a download
            # from https://gpgtools.org/installer/index.html - newer versions should
            # install similarly
            packages::pkgdmg {
                GPGTools:
                    version             => '20111224',
                    os_version_specific => false,
                    before              => File['/Library/LaunchAgents/org.gpgtools.macgpg2.gpg-agent.plist.plist'];
            }

            # and, this file is bogus and causes warnings:
            file {
                '/Library/LaunchAgents/org.gpgtools.macgpg2.gpg-agent.plist.plist':
                    ensure => absent;
            }
        }

        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
