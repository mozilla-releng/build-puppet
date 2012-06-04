define ccache::ccache_dir($owner, $maxsize, $mode=0755) {
    include packages::ccache

    $ccache_dir=$name

    file {
        $ccache_dir:
            ensure => directory,
            owner => $owner,
            group => $owner,
            mode => 0755;
        "$ccache_dir/.puppet-maxsize":
            content => "$maxsize",
            notify => Exec["ccache-maxsize-$ccache_dir"];
    }

    exec {
        "ccache-maxsize-$ccache_dir":
            require => [File[$ccache_dir], Class["packages::ccache"]],
            refreshonly => true,
            command => "/usr/bin/ccache -M$maxsize",
            environment => [
                "CCACHE_DIR=$ccache_dir",
                ],
            user => $owner;
    }
}
