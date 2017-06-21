# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Python Psutil original package available at https://pypi.python.org/packages/2.7/p/psutil/psutil-2.1.1.win32-py2.7.exe#md5=5d51ac4843a4cc8407d0be0e2d3d0eac
# This package has been manual repackage using 7zip.
# The reason for the repackaging is some directory structure has been reorganized to prevent other processes from breaking.
# Ref. https://bugzilla.mozilla.org/show_bug.cgi?id=918992

class packages::psutil {
    packages::pkgzip {'psutil.zip':
        zip        => 'psutil.zip',
        target_dir => 'C:\mozilla-build\sitepackages';
    }
}
