# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mozilla::python35 {

    anchor {
        'packages::mozilla::python35::begin': ;
        'packages::mozilla::python35::end': ;
    }

    case $::operatingsystem {
        CentOS: {
            $python3 = '/tools/python35/bin/python3.5'

            # these all install into /tools/python35.  To support tools that
            # just need any old Python3, they are symlinked from /tools/python3.
            Anchor['packages::mozilla::python35::begin'] ->
            file {
                '/tools/python3':
                    ensure => link,
                    target => '/tools/python35';
            } -> Anchor['packages::mozilla::python35::end']

            realize(Packages::Yumrepo['python35'])
            Anchor['packages::mozilla::python35::begin'] ->
            package {
                'mozilla-python35':
                    ensure => '3.5.2-1.el6';
            } -> Anchor['packages::mozilla::python35::end']
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
