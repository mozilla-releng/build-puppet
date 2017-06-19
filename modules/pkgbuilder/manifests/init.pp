# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class pkgbuilder {
    include config

    case $::operatingsystem {
        Ubuntu: {
            # On Ubuntu, we use cowbuilder along with a custom script to build packages
            include packages::cowbuilder
            include packages::debian_keyring
            file {
                '/etc/pbuilderrc':
                    content => template("${module_name}/pbuilderrc.erb");
                '/root/pbuilderrc':
                    ensure => absent;
                '/usr/local/bin/puppetagain-build-deb':
                    source => "puppet:///modules/${module_name}/puppetagain-build-deb",
                    mode   => '0755';
            }

            pkgbuilder::base_cow {
                'precise-i386': ;
                'precise-amd64': ;
                'trusty-i386': ;
                'trusty-amd64': ;
            }
        }
        CentOS: {
            include packages::mock

            # add all admin_users to the mock group.  Puppet's group provider can't handle
            # this, and building an augeas script from an array of usernames would require
            # custom functions.  But sed can do it!
            $users = join($config::admin_users, ',')
            exec {
                'mock-group':
                    require => Class['packages::mock'],
                    command => "/bin/sed -i -e '/^mock:/s/^\\(mock:[^:]*:[^:]*:\\).*/\\1${users}/' /etc/group";
            }

            file {
                '/etc/mock':
                    ensure  => directory,
                    recurse => true,
                    force   => true,
                    purge   => true,
                    source  => "puppet:///modules/${module_name}/mock-config";
            }
        }
        default: {
            fail("pkgbuilder is not spuported on ${::operatingsystem}")
        }
    }
}

