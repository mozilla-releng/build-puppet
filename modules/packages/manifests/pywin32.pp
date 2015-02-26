# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# pywin32-218.win32-py2.7.exe  original package available at http://sourceforge.net/projects/pywin32/files/pywin32/Build%20218/
# This package has been manual repackage using 7zip.
# The original exe file did not accept cmd line arguments for installation.
# The exe was extracting and re-zipped into the 2 files below. 
# Removing parent directories and allowing the packages being extracted to the proper directories. 
class packages::pywin32 {
    packages::pkgzip {"pywin32-218.win32-py2.7-LIB.zip":
        zip => "pywin32-218.win32-py2.7-LIB.zip",
        target_dir => 'C:\mozilla-build\python\lib\site-packages';
    }
    packages::pkgzip {"pywin32-218.win32-py2.7-SCRIPTS.zip":
        zip => "pywin32-218.win32-py2.7-SCRIPTS.zip",
        target_dir => 'C:\mozilla-build\python\scripts';
    }
}
