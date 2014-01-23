# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define casper::casperuser ($user = $title, $uid) {

    if (secret("${user}_pw_pbkdf2") == '' or secret("${user}_pw_pbkdf2_salt") == '' or secret("${user}_pw_pbkdf2_iterations") == '') {
        fail("No pbkdf2 password set for ${user}")
    }

    $grp = $user

    group { $grp :
        ensure  => present;
    }

    user { $user :
        ensure  => present,
        uid     => $uid,
        gid     => $grp,
        shell   => '/bin/bash',
        home    => "/Users/${user}",
        password => secret("${$user}_pw_pbkdf2"),
        salt => secret("${$user}_pw_pbkdf2_salt"),
        iterations => secret("${$user}_pw_pbkdf2_iterations"),
        comment => $user;
    }

    file { "/Users/${user}" :
        ensure => directory,
        owner  => $user,
        group  => $grp,
        mode   => 0755;
    }
}
