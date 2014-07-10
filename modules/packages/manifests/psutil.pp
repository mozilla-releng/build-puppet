# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# All buildbot slaves (both build and test) are subclasses of this class.

class packages::psutil {
    # Python Psutil -- original package available at https://pypi.python.org/packages/2.7/p/psutil/psutil-2.1.1.win32-py2.7.exe#md5=5d51ac4843a4cc8407d0be0e2d3d0eac
    # This package has been manually repackaged using 7zip. 
    # The reason for the repackaging is some directory structure has been reorganized to prevent other processes from breaking.
    # Ref. https://bugzilla.mozilla.org/show_bug.cgi?id=918992
    exec { "psutil":
        creates => 'C:\mozilla-build\sitepackages\_psutil_mswindows.pyd',
        require => Class["packages::7z920"],
        command => '"C:\Program Files (x86)\7-Zip\7z.exe" x C:\InstallerSource\puppetagain.pub.build.mozilla.org\ZIPs\psutil.zip -oC:\mozilla-build\sitepackages -y'
    }
}  
