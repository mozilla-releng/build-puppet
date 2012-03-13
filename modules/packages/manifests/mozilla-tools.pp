# This is a class that describes a fairly generic set of mozilla
# tools packages

class packages::mozilla-tools {

    case $operatingsystem{
        CentOS: {
            package {
                "mozilla-python27":
                    ensure => latest;
                "mozilla-python26":
                    ensure => latest;
                "mozilla-python27-mercurial":
                    ensure => latest;
                "mozilla-python27-virtualenv":
                    ensure => latest;
                "mozilla-git":
                    ensure => latest;
            }
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    }

}
