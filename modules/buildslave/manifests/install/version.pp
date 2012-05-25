# install a particular version of the buildslave code
#
# title: version number
# active: if true, make /tools/buildbot point here (default false)
# ensure: present/absent
define buildslave::install::version($active=false, $ensure="present") {
    $version = $title

    # set the parameters for the virtualenv below.  Each version should set
    # $packages explicitly.
    case $version {
        "0.8.4-pre-moz2": {
            include packages::mozilla::python27
            $python = "/tools/python27/bin/python2.7"
            $py_require = Class['packages::mozilla::python27']
            $packages = [
                          "zope.interface==3.6.1",
                          "buildbot-slave==$version",
                          # buildbot (master) is needed for buildbot sendchange
                          "buildbot==$version",
                          "Twisted==10.2.0",
                          # this is required for some mozilla custom classes
                          "simplejson==2.1.3" ]
        }

        default: {
            fail("unrecognized buildbot version $version")
        }
    }

    case $ensure {
        present: {
            python::virtualenv {
                "/tools/buildbot-$version":
                    python => $python,
                    require => $py_require,
                    packages => $packages;
            }

            if $active {
                file {
                    "/tools/buildbot":
                        ensure => "link",
                        target => "/tools/buildbot-$version";
                }
            }
        }

        absent: {
            # absent? that's easy - blow away the directory
            python::virtualenv {
                "/tools/buildbot-$version":
                    python => $python,
                    packages => $packages,
                    ensure => absent;
            }
        }
    }
}

