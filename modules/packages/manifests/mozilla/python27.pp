# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mozilla::python27 {

    # these all install into /tools/python27.  To support tools that just need
    # any old Python, they are symlinked from /tools/python.  For tools that know
    # they will need Python 2.x but don't care about x, there's /tools/python2.
    # When we support Python-3.x, there will be /tools/python3 as well.

    $python = '/tools/python27/bin/python2.7'
    anchor {
        'packages::mozilla::python27::begin': ;
        'packages::mozilla::python27::end': ;
    }

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
                    ensure => latest;
            } -> Anchor['packages::mozilla::python27::end']
        }
        Ubuntu: {
            Anchor['packages::mozilla::python27::begin'] ->
            package {
                "python2.7":
                    ensure => latest;
            } -> Anchor['packages::mozilla::python27::end']
            Anchor['packages::mozilla::python27::begin'] ->
            package {
                "python2.7-dev":
                    ensure => latest;
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
                    version => "2.7.2-1";
            } -> Anchor['packages::mozilla::python27::end']
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
