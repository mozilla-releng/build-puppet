# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::openssh {

    anchor {
        'packages::openssh::begin': ;
        'packages::openssh::end': ;
    }

    # For non-jumphosts, see security_updates.pp for openssh

    case $::operatingsystem {
        CentOS: {
            realize(Packages::Yumrepo['openssh'])
            Anchor['packages::openssh::begin'] ->
            package {
                [ 'openssh-server', 'openssh-clients', 'openssh' ] :
                    ensure => '6.6p1-1';
            } -> Anchor['packages::openssh::end']
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
