# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class bmm::httpd {
    include ::httpd

    httpd::config {
        "bmm_httpd.conf" :
            content => template("bmm/bmm_httpd.conf.erb");
    }

    file {
       "/opt/bmm/www":
            ensure => directory;
        "/opt/bmm/www/scripts":
            ensure => directory;
        "/opt/bmm/www/squashfs":
            recurse => true,
            purge => true,
            source => [ "puppet:///bmm/squashfs", "puppet:///bmm/private/squashfs" ],
            sourceselect => all,
            ensure => directory,
            show_diff => false;
       "/opt/bmm/www/artifacts":
            recurse => true,
            purge => true,
            source => [ "puppet:///bmm/artifacts", "puppet:///bmm/private/artifacts" ],
            sourceselect => all,
            ensure => directory,
            show_diff => false;
    }

    bmm::script {
        "liveutil.sh": ;
        "android-second-stage.sh": ;
        "b2g-second-stage.sh": ;
        "maintenance-second-stage.sh": ;
        "selftest-second-stage.sh": ;
        "selftest-second-stage.py": ;
        "panda_selftest.1.json": ;
        "fix-boot-scr.sh": ;
    }
}
