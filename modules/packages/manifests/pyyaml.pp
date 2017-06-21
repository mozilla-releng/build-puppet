# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::pyyaml {
    case $::operatingsystem {
        CentOS: {
            package {
                'PyYAML':
                    ensure => '3.09-5.el6';
            }
        }

        Ubuntu: {
            package {
                'python-yaml':
                    ensure => present;
            }
        }
        Windows: {
            include buildslave::install

            packages::pkgzip {
                'PyYAML-3.11.zip':
                    require    => Class['buildslave::install'],
                    zip        => 'PyYAML-3.11.zip',
                    target_dir => '"C:\Mozilla-Build\"';
            }
            exec {
                'pyyaml_setup':
                    require => Packages::Pkgzip['PyYAML-3.11.zip'],
                    command => "C:\\mozilla-build\\buildbotve\\Scripts\\python.exe C:\\mozilla-build\\PyYAML-3.11\\setup.py install",
                    cwd     => "C:\\mozilla-build\\PyYAML-3.11",
                    creates => "C:\\mozilla-build\\buildbotve\\Lib\\site-packages\\PyYAML-3.11-py2.7.egg-info";
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
