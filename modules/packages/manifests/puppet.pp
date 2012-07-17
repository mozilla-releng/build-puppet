class packages::puppet {
    $puppet_version = "2.7.11-2.el6"

    package {
        "puppet":
            ensure => "$puppet_version";
    }
}
