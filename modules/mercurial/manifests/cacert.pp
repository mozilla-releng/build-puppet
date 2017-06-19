# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# install cacert.pem and place it in /etc/mercurial/ (Ubuntu, CentOS and Darwin)

class mercurial::cacert {
    case $operatingsystem {
        CentOS,Ubuntu,Darwin: {
            include dirs::builds
            file {
                '/builds/mercurial-certs':
                    ensure => directory,
                    mode   => '0755';

                '/builds/mercurial-certs/cacert.pem':
                    ensure => file,
                    source => 'puppet:///modules/mercurial/cacert.pem',
                    owner  => 'root';
            }
        }
        Windows: {
            file {
                'C:/mozilla-build/hg/cacert.pem':
                    ensure => file,
                    source => 'puppet:///modules/mercurial/cacert.pem';
            }
        }
    }
}

