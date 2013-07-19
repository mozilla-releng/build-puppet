# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class signingserver::base {
    include dirs::builds
    include users::signer

    # OS X does not yet support firewall manipulation
    if $::operatingsystem != 'Darwin' {
        include fw
    }

    # lots of packages for signing, with some differing between operating
    # systems
    include packages::mozilla::python27
    include packages::mozilla::py27_mercurial
    include packages::libevent
    include packages::mozilla::signmar
    include packages::mozilla::signing_test_files
    include packages::gnupg

    case $::operatingsystem {
        CentOS: {
            include packages::mono
            include packages::openssl
            include packages::nss_tools
            include packages::libevent
            include packages::jdk16
            include packages::gcc
            include packages::mozilla::android_sdk16

            $compiler_req = Class['packages::gcc']
        }
        Darwin: {
            include packages::xcode

            $compiler_req = Class['packages::xcode']
        }
    }

    $root = "/builds/signing"

    file {
        # instances are stored with locked-down perms
        $root:
            ensure => directory,
            owner => $users::signer::username,
            group => $users::signer::group,
            mode => '0700';
    }

    motd {
        "signing":
            content => "This signing server hosts the following instances:\n",
            order => 90;
    }

    # NOTE: on CentOS, packages::jdk16 installs jarsigner in the default PATH
    # lrwxrwxrwx 1 root root 27 Jun 26 10:54 /usr/bin/jarsigner -> /etc/alternatives/jarsigner
}
