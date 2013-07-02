# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class signingserver::base {
    include dirs::builds
    include users::signer
    include fw

    # lots of packages for signing:
    include packages::mono
    include packages::openssl
    include packages::gnupg
    include packages::nss_tools
    include packages::libevent
    include packages::jdk16
    include packages::gcc
    include packages::mozilla::python27
    include packages::mozilla::py27_mercurial
    include packages::mozilla::signmar
    include packages::mozilla::signing_test_files
    include packages::mozilla::android_sdk16
    include packages::mozilla::signmar

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
