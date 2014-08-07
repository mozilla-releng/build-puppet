# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# All buildbot slaves (both build and test) are subclasses of this class.

# The KTS package is repackage of the source found at http://www.kpym.com/2/kpym/index.htm
# The original package did not accept installation arguments.
class packages::kts {
    packages::pkgzip {"KTS.zip":
        zip => "KTS.zip",
        target_dir => '"C:\program files\KTS"';
    }

}
