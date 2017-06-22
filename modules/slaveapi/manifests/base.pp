# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class slaveapi::base {
    include dirs::builds
    include users::builder

    include packages::mozilla::python27
    include packages::libevent
    include packages::openssl
    include packages::libevent
    include packages::gcc
    include packages::openipmi
    include packages::snmp

    include nrpe::check::procs_regex

    $compiler_req = Class['packages::gcc']

    $root         = '/builds/slaveapi'

    file {
        # instances are stored with locked-down perms
        $root:
            ensure => directory,
            owner  => $users::builder::username,
            group  => $users::builder::group,
            mode   => '0700';
    }

    motd {
        'slaveapi':
            content => "The following slaveapi instances are hosted here:\n",
            order   => 90;
    }
}
