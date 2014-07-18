# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mockbuild {
    include packages::mozilla::mock_mozilla
    include mockbuild::services

    file {
        "/etc/mock_mozilla/mozilla-f16-x86_64.cfg":
            require => Class["packages::mozilla::mock_mozilla"],
            source => "puppet:///modules/mockbuild/mozilla-f16-x86_64.cfg";
        "/etc/mock_mozilla/mozilla-f16-i386.cfg":
            require => Class["packages::mozilla::mock_mozilla"],
            source => "puppet:///modules/mockbuild/mozilla-f16-i386.cfg";
        "/etc/mock_mozilla/mozilla-centos6-i386.cfg":
            require => Class["packages::mozilla::mock_mozilla"],
            source => "puppet:///modules/mockbuild/mozilla-centos6-i386.cfg",
            notify => Exec['mock_clean_mozilla-centos6-i386'];
        "/etc/mock_mozilla/mozilla-centos6-x86_64.cfg":
            require => Class["packages::mozilla::mock_mozilla"],
            source => "puppet:///modules/mockbuild/mozilla-centos6-x86_64.cfg",
            notify => Exec['mock_clean_mozilla-centos6-x86_64'];
        # make sure that the directory exists for cases when
        # /builds/mock_mozilla is mounted on a non persistent volumes (like EC2
        # instance storage)
        "/builds/mock_mozilla":
            require => Class["packages::mozilla::mock_mozilla"],
            ensure  => "directory",
            owner   => "root",
            group   => "mock_mozilla",
            mode    => 2775;
    }
    exec {
        'mock_clean_mozilla-centos6-i386':
            # this will expire all mock caches
            command => "/usr/bin/sudo -u $::config::builder_username /usr/bin/mock_mozilla -v -r mozilla-centos6-i386 --scrub=all",
            onlyif => "/usr/bin/test -e /builds/mock_mozilla/mozilla-centos6-i386/result/state.log",
            refreshonly => true;
        'mock_clean_mozilla-centos6-x86_64':
            # this will expire all mock caches
            command => "/usr/bin/sudo -u $::config::builder_username /usr/bin/mock_mozilla -v -r mozilla-centos6-x86_64 --scrub=all",
            onlyif => "/usr/bin/test -e /builds/mock_mozilla/mozilla-centos6-x86_64/result/state.log",
            refreshonly => true;
    }
}
