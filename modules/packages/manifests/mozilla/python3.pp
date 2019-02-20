# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mozilla::python3 {

    anchor {
        'packages::mozilla::python3::begin': ;
        'packages::mozilla::python3::end': ;
    }

    case $::operatingsystem {
        CentOS: {
            $python3 = '/tools/python3/bin/python'

            # these install into /tools/python36.  To support tools that
            # just need any old Python3, they are symlinked from /tools/python3.
            Anchor['packages::mozilla::python3::begin'] ->
            file {
                '/tools/python3':
                    ensure => link,
                    target => '/tools/python36';
            } -> Anchor['packages::mozilla::python3::end']

            realize(Packages::Yumrepo['python3'])
            Anchor['packages::mozilla::python3::begin'] ->
            package {
                'mozilla-python36':
                    ensure => '3.6.5-2.el6';
            } -> Anchor['packages::mozilla::python3::end']
        }
        Darwin: {
            case $::macosx_productversion_major {
                '10.10': {
                    $python3 = '/tools/python37/bin/python3.7'

                    # Install python37 into /tools/python37 on OSX workers
                    Anchor['packages::mozilla::python3::begin'] ->
                    file {
                        '/tools/python3':
                            ensure => link,
                            target => '/tools/python37';
                        '/usr/local/bin/python3':
                            ensure => link,
                            target => '/tools/python37/bin/python3.7';
                        '/etc/profile.d/append-python37-path.sh':
                            mode    => '0755',
                            content => 'PATH=$PATH:/tools/python37/bin/python3.7',
                    } -> Anchor['packages::mozilla::python3::end']

                    Anchor['packages::mozilla::python3::begin'] ->
                    packages::pkgdmg {
                        'python37':
                            os_version_specific => true,
                            version             => '3.7.1-1';
                        'xz':
                            os_version_specific => true,
                            version             => '5.2.4-1';
                    }  -> Anchor['packages::mozilla::python3::end']
                }
                default: {
                    fail("Cannot install on Darwin version ${::macosx_productversion_major}")
                }
            }
        }
        Ubuntu: {
            # Because we are in the migration process from taskcluster-worker to generic-worker
            # I added the case entry for Ubuntu, to avoid the error message:
            # Cannot install on Ubuntu, when run puppet on Ubuntu machines

            # Added python3 information, to avoid error: $python3 must be defined in this manifest file
            # when run puppet on Ubuntu machines
            $python3 = ' '

            # Python3 installation on Ubuntu machines will be part os other bug
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }

    # sanity check
    if (!$python3) {
        fail("\$python3 must be defined in this manifest file")
    }
}
