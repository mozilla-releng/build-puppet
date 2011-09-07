# Install the required version of puppet
class puppet::install {
    $puppet_version = "2.7.1-1.el6"

    package {
        "puppet":
            ensure => "$puppet_version";
    }
}
