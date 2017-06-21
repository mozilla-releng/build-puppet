# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# pywin32-218.win32-py2.7.exe  original package available at http://sourceforge.net/projects/pywin32/files/pywin32/Build%20218/
class packages::pywin32 {
    include packages::mozilla::python27
    include config

    exec { 'pywin32':
        require => Class['packages::mozilla::python27'],
        command => "C:\\mozilla-build\\python27\\Scripts\\easy_install.exe  http://${config::puppet_server}/repos/EXEs/pywin32-218.win32-py2.7.exe",
        creates => "C:\\mozilla-build\\pyhton27\\Lib\\site-packages\\pywin32-218-py2.7-win32.egg";
    }
}
