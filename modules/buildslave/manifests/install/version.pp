# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# install a particular version of the buildslave code
#
# title: version number
# active: if true, make /tools/buildbot point here (default false)
# ensure: present/absent
define buildslave::install::version($active=false, $ensure="present") {
    $version = $title
        $virtualenv_path = $::operatingsystem ? {
            windows => "c:\\mozilla-build\\buildbot-$version",
            default => "/tools/buildbot-$version",
        }

    anchor {
        "buildslave::install::version::${version}::begin": ;
        "buildslave::install::version::${version}::end": ;
    }

    # set the parameters for the virtualenv below.  Each version should set
    # $packages explicitly.
    case $version {
        "0.8.4-pre-moz2", "0.8.4-pre-moz3", "0.8.4-pre-moz4", "0.8.4-pre-moz5", "0.8.4-pre-moz6": {
            include packages::mozilla::python27
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
            Anchor["buildslave::install::version::${version}::begin"] ->
            python::virtualenv {
                "$virtualenv_path":
                    python => $::packages::mozilla::python27::python,
                    require => $py_require,
                    packages => $packages;
            } -> Anchor["buildslave::install::version::${version}::end"]
            if ($active) {
                case $::operatingsystem {
                    Windows: {
                        file {
                            "C:/mozilla-build/bbpath.bat":
                                content => "set BUILDBOT_PATH=$virtualenv_path";
                        }
                    }
                    default: {
                        Anchor["buildslave::install::version::${version}::begin"] ->
                            file {
                                "/tools/buildbot":
                                    ensure => "link",
                                    target => "$virtualenv_path";
                        } -> Anchor["buildslave::install::version::${version}::end"]
                    }
                }
            }
        }
        absent: {
            # absent? that's easy - blow away the directory
            python::virtualenv {
                 "$virtualenv_path":
                    python => $::packages::mozilla::python27::python,
                    packages => $packages,
                    ensure => absent;
            }
        }
    }
}
