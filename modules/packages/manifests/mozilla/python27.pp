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
                    if ($::hostname in [ 'buildduty-tools', 'cruncher-aws', 'aws-manager1', 'aws-manager2',
                                        'treescriptworker-dev1', 'treescriptworker1', 'slaveapi1',
                                        'slaveapi-dev1', 'slaveapi1', 'dev-master2',
                                        'buildbot-master01', 'buildbot-master02', 'buildbot-master04',
                                        'buildbot-master05', 'buildbot-master51', 'buildbot-master52',
                                        'buildbot-master53', 'buildbot-master54', 'buildbot-master69',
                                        'buildbot-master71', 'buildbot-master72', 'buildbot-master73',
                                        'buildbot-master75', 'buildbot-master77', 'buildbot-master78',
                                        'buildbot-master82', 'buildbot-master83', 'buildbot-master84',
                                        'buildbot-master86', 'buildbot-master87', 'buildbot-master103',
                                        'buildbot-master104', 'buildbot-master105', 'buildbot-master106',
                                        'buildbot-master107', 'buildbot-master109', 'buildbot-master110',
                                        'buildbot-master111', 'buildbot-master128', 'buildbot-master137',
                                        'buildbot-master138', 'buildbot-master139', 'buildbot-master140', ])
                          or ($::hostname =~ /^balrogworker-dev\d+/)
                          or ($::hostname =~ /^balrogworker-\d+/)
                    {
                      realize(Packages::Yumrepo['python27-15'])
                      Anchor['packages::mozilla::python27::begin'] ->
                      package {
                          'mozilla-python27':
                              ensure => '2.7.15-1.el6';
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
                    case $::macosx_productversion_major {
                        '10.6','10.8','10.9','10.10': {
                            if $::hostname in [ 'mac-v2-signing-fake' ] {
                                Anchor['packages::mozilla::python27::begin'] ->
                                packages::pkgdmg {
                                    'python27':
                                        version => '2.7.15-1';
                                }  -> Anchor['packages::mozilla::python27::end']
                            }
                            else {
                                Anchor['packages::mozilla::python27::begin'] ->
                                packages::pkgdmg {
                                    'python27':
                                        version => '2.7.3-1';
                                }  -> Anchor['packages::mozilla::python27::end']
                            }
                        }
                        '10.7': {
                            Anchor['packages::mozilla::python27::begin'] ->
                            packages::pkgdmg {
                                'python27':
                                    os_version_specific => true,
                                    version             => '2.7.12-1';
                            }  -> Anchor['packages::mozilla::python27::end']
                        }
                        default: {
                            fail("Cannot install on Darwin version ${::macosx_productversion_major}")
                        }
                    }
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
