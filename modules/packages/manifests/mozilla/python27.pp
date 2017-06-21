# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mozilla::python27 {

    anchor {
        'packages::mozilla::python27::begin': ;
        'packages::mozilla::python27::end': ;
    }

    case $::operatingsystem {
        windows: {
            include packages::mozilla::mozilla_build

            Anchor['packages::mozilla::python27::begin'] ->
                Class['packages::mozilla::mozilla_build'] ->
            Anchor['packages::mozilla::python27::end']

            # on windows, we get Python from mozilla-build.
            $pythondir = "C:\\mozilla-build\\python27"
            $python    = "${pythondir}\\python2.7.exe"

        }
        default: {
            # everywhere else, we install from a custom-built package
            $python = '/tools/python27/bin/python2.7'

            # these all install into /tools/python27.  To support tools that
            # just need any old Python, they are symlinked from /tools/python.
            # For tools that know they will need Python 2.x but don't care
            # about x, there's /tools/python2.  When we support Python-3.x,
            # there will be /tools/python3 as well.
            Anchor['packages::mozilla::python27::begin'] ->
            file {
                '/tools/python':
                    ensure => link,
                    target => '/tools/python27';
                '/tools/python2':
                    ensure => link,
                    target => '/tools/python27';
            } -> Anchor['packages::mozilla::python27::end']

            case $::operatingsystem {
                CentOS: {
                    # Bug 1307757 - Deploy python 2.7.12 to releng servers
                    # install Python 2.7.12 for 'buildduty-tools' and 'cruncher-aws' servers in order
                    # to silence the alerts caused by using on older Python version (2.7.3) when
                    # performing HG operation.
                    if $::hostname in [ 'buildduty-tools', 'cruncher-aws' ] {
                      realize(Packages::Yumrepo['python27-12'])
                      Anchor['packages::mozilla::python27::begin'] ->
                      package {
                          'mozilla-python27':
                              ensure => '2.7.12-1.el6';
                      } -> Anchor['packages::mozilla::python27::end']
                    }
                    else {
                      Anchor['packages::mozilla::python27::begin'] ->
                      package {
                          'mozilla-python27':
                              ensure => '2.7.3-1.el6';
                      } -> Anchor['packages::mozilla::python27::end']
                    }
                }
                Ubuntu: {
                    case $::operatingsystemrelease {
                        12.04: {
                            Anchor['packages::mozilla::python27::begin'] ->
                            package {
                                [ 'python2.7', 'python2.7-dev']:
                                    ensure => '2.7.3-0ubuntu3';
                            } -> Anchor['packages::mozilla::python27::end']
                        }
                        16.04: {
                            Anchor['packages::mozilla::python27::begin'] ->
                            package {
                                [ 'python2.7', 'python2.7-dev']:
                                    ensure => '2.7.12-1ubuntu0~16.04.1';
                            } -> Anchor['packages::mozilla::python27::end']
                            # After Ubuntu 12.04, the _sysconfigdata_nd.py was moved from /usr/lib/python2.7 to /usr/lib/python2.7/plat-x86_64-linux-gnu/
                            # I needed to create a symlink to this file in /usr/lib/python2.7 to install virtualenv
                            file {
                                '/usr/lib/python2.7/_sysconfigdata_nd.py':
                                    ensure => link,
                                    target => '/usr/lib/python2.7/plat-x86_64-linux-gnu/_sysconfigdata_nd.py';
                            }
                        }
                        default: {
                            fail("Cannot install on Ubuntu version ${::operatingsystemrelease}")
                        }
                    }
                    # Create symlinks for compatibility with other platforms
                    file {
                        ['/tools/python27', '/tools/python27/bin']:
                            ensure => directory;
                        [$python, '/usr/local/bin/python2.7']:
                            ensure => link,
                            target => '/usr/bin/python';
                    }
                }
                Darwin: {
                    Anchor['packages::mozilla::python27::begin'] ->
                    packages::pkgdmg {
                        'python27':
                            version => '2.7.3-1';
                    } -> Anchor['packages::mozilla::python27::end']
                }
                default: {
                    fail("Cannot install on ${::operatingsystem}")
                }
            }
        }
    }

    # sanity check
    if (!$python) {
        fail("\$python must be defined in this manifest file")
    }
}
