# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# install cacert.pem and place it in /etc/mercurial/ (Ubuntu, CentOS and Darwin)

class mercurial::cacert {
    case $operatingsystem {
        CentOS,Ubuntu,Darwin: {
            file {
                '/etc/mercurial/cacert':
                    ensure => directory,
                    mode => 0755;

                '/etc/mercurial/cacert/cacert.pem':
                    ensure => file,
                    source => "puppet:///modules/mercurial/cacert.pem",
                    owner => "root";
            }
        }
    }
}

