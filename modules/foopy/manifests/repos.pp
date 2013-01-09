# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class foopy::repos {
    include users::builder
    include dirs::tools
    include dirs::builds

    include config

    $frozen_talos_rev = "cb1b7a64f98e"

    file {
        "/builds/tools":
            owner => $users::builder::username,
            group => $users::builder::group,
            ensure => directory,
            mode => 0755;
        ["/builds/talos-data", "/builds/talos-data/talos-repo"]:
            owner => $users::builder::username,
            group => $users::builder::group,
            ensure => directory,
            mode => 0755;
    }
    exec {
        "clone-tools":
            require => [
                Class['packages::mozilla::py27_mercurial'],
                File['/builds/tools'],
            ],
            creates => "/builds/tools/.hg",
            command => "$::packages::mozilla::py27_mercurial::mercurial clone http://hg.mozilla.org/build/tools /builds/tools",
            user => $users::builder::username;
        "clone-talos":
            require => [
                Class['packages::mozilla::py27_mercurial'],
                File['/builds/talos-data/talos-repo'],
            ],
            creates => "/builds/talos-data/talos-repo/.hg",
            command => "$::packages::mozilla::py27_mercurial::mercurial clone -u $frozen_talos_rev http://hg.mozilla.org/build/talos /builds/talos-data/talos-repo",
            user => $users::builder::username;
    }
    file {
        # Create sut_tools where our code expects to find it.
        "/builds/sut_tools":
            owner => $users::builder::username,
            group => $users::builder::group,
            ensure => link,
            target => "/builds/tools/sut_tools",
            require => Exec["clone-tools"];

        # Create talos where our code expects to find it
        "/builds/talos-data/talos":
            owner => $users::builder::username,
            group => $users::builder::group,
            ensure => link,
            target => "/builds/talos-data/talos-repo/talos",
            require => Exec["clone-talos"];

        # Link these from talos to where our tools need them
        "/builds/sut_tools/devicemanager.py":
            owner => $users::builder::username,
            group => $users::builder::group,
            ensure => link,
            target => "/builds/talos-data/talos-repo/talos/devicemanager.py";
        "/builds/sut_tools/devicemanagerSUT.py":
            owner => $users::builder::username,
            group => $users::builder::group,
            ensure => link,
            target => "/builds/talos-data/talos-repo/talos/devicemanagerSUT.py";
        "/builds/sut_tools/devicemanagerADB.py":
            owner => $users::builder::username,
            group => $users::builder::group,
            ensure => link,
            target => "/builds/talos-data/talos-repo/talos/devicemanagerADB.py";
    }
}
