# This is a class that describes a fairly generic set of mozilla
# tools packages

class packages::mozilla-tools {

    case $operatingsystem{
        CentOS: {
            # These are mozilla custom tools
            package {
                "mozilla-python27":
                    ensure => latest;
                "mozilla-python26":
                    ensure => latest;
                "mozilla-python27-setuptools":
                    ensure => latest;
                "mozilla-python26-setuptools":
                    ensure => latest;
                "mozilla-python27-mercurial":
                    ensure => latest;
                "mozilla-python27-virtualenv":
                    ensure => latest;
                "mozilla-python27-twisted":
                    ensure => latest;
                "mozilla-git":
                    ensure => latest;
                "mock_mozilla":
                    ensure => latest;
            }
            # These are upstream CentOS packages we want
            package {
                "mock": ensure => latest;
                "createrepo": ensure => latest;

            }

            # The puppet group type can't do this it seems
            exec {
                "mock_mozilla-add":
                    require => [Package["mock_mozilla"],User["$config::builder_username"]],
                    command => "/usr/bin/gpasswd -a $config::builder_username mock_mozilla";
                "mock-add":
                    require => [Package["mock"],User["$config::builder_username"]],
                    command => "/usr/bin/gpasswd -a $config::builder_username mock";
            }
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    }

}
