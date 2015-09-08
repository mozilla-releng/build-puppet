# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# this class simply invokes the resource type with the production version
class buildslave::install {
    include packages::mozilla::python27

    anchor {
        'buildslave::install::begin': ;
        'buildslave::install::end': ;
    }

    $version = "0.8.4-pre-moz7" # N.B. used by runner

    $virtualenv_path = $::operatingsystem ? {
        windows => "c:\\mozilla-build\\buildbot-$version",
        default => "/tools/buildbot-$version",
    }

    $py_require = Class['packages::mozilla::python27']
    $packages = [
        "zope.interface==3.6.1",
        "buildbot-slave==$version",
        # buildbot (master) is needed for buildbot sendchange
        "buildbot==$version",
        "Twisted==10.2.0",
        # this is required for some mozilla custom classes
        "simplejson==2.1.3" ]

    Anchor["buildslave::install::begin"] ->
    python::virtualenv {
        "$virtualenv_path":
            python => $::packages::mozilla::python27::python,
            require => $py_require,
            packages => $packages;
    } -> Anchor["buildslave::install::end"]

    case $::operatingsystem {
        Windows: {
            file {
                "C:/mozilla-build/bbpath.bat":
                    content => "set BUILDBOT_PATH=$virtualenv_path";
            }
            # Append the virtual environment directory to the Windows path
            windows_path {
                "$virtualenv_path":
                    ensure => present;
            }
        }
        default: {
            Anchor["buildslave::install::begin"] ->
            file {
                "/tools/buildbot":
                    ensure => "link",
                    target => "$virtualenv_path";
            } -> Anchor["buildslave::install::end"]
        }
    }
}
