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
            $python = 'C:\mozilla-build\python\python2.7.exe'

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
                "/tools/python":
                    ensure => link,
                    target => "/tools/python27";
                "/tools/python2":
                    ensure => link,
                    target => "/tools/python27";
            } -> Anchor['packages::mozilla::python27::end']

            case $::operatingsystem {
                CentOS: {
                    Anchor['packages::mozilla::python27::begin'] ->
                    package {
                        "mozilla-python27":
                            ensure => '2.7.3-1.el6';
                    } -> Anchor['packages::mozilla::python27::end']
                }
                Ubuntu: {
                    Anchor['packages::mozilla::python27::begin'] ->
                    package {
                        "python2.7":
                            ensure => '2.7.3-0ubuntu3';
                    } -> Anchor['packages::mozilla::python27::end']
                    Anchor['packages::mozilla::python27::begin'] ->
                    package {
                        "python2.7-dev":
                            ensure => '2.7.3-0ubuntu3';
                    } -> Anchor['packages::mozilla::python27::end']

                    # Create symlinks for compatibility with other platforms
                    file {
                        ["/tools/python27", "/tools/python27/bin"]:
                            ensure => directory;
                        [$python, "/usr/local/bin/python2.7"]:
                            ensure => link,
                            target => "/usr/bin/python";
                    }
                }
                Darwin: {
                    Anchor['packages::mozilla::python27::begin'] ->
                    packages::pkgdmg {
                        python27:
                            version => "2.7.3-1";
                    } -> Anchor['packages::mozilla::python27::end']
                }
                default: {
                    fail("cannot install on $::operatingsystem")
                }
            }
        }
    }

    # sanity check
    if (!$python) {
        fail("\$python must be defined in this manifest file")
    }
}
