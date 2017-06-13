# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define ccache::ccache_dir($owner, $group, $maxsize, $mode=0755) {
    include packages::mozilla::ccache

    $ccache_dir=$name

    # for the moment, the Darwin DMG puts things in funny places
    $ccache = $::operatingsystem ? {
        Darwin  => '/usr/local/bin/ccache',
        default => '/usr/bin/ccache',
    }

    file {
        $ccache_dir:
            ensure => directory,
            owner  => $owner,
            group  => $group,
            mode   => $mode;
        "${ccache_dir}/.puppet-maxsize":
            content => $maxsize,
            notify  => Exec["ccache-maxsize-${ccache_dir}"];
    }

    exec {
        "ccache-maxsize-${ccache_dir}":
            require     => [File[$ccache_dir], Class['packages::mozilla::ccache']],
            refreshonly => true,
            command     => "${ccache} -M${maxsize}",
            environment => [
                "CCACHE_DIR=${ccache_dir}",
                ],
            user        => $owner;
    }
}
