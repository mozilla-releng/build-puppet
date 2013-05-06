define bors::install($basedir, $owner, $group, $version) {
    include packages::mozilla::python27

    python::virtualenv {
        "${basedir}":
            python => $::packages::mozilla::python27::python,
            require => Class['packages::mozilla::python27'],
            user => $owner,
            group => $group,
            packages => [
                "bors==${version}",
            ];
    }
}
