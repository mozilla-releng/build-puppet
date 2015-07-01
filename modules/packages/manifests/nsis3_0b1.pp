# Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# NSIS-3.0.b1 is originally sourced from http://nsis.sourceforge.net/Download
# It is repackaged into a zip file due to the source package did not accept command line arguments

class packages::nsis3_0b1 {
    include packages::mozilla::mozilla_build 

    packages::pkgzip {"nsis-3.0b1.zip":
        require    => Class[packages::mozilla::mozilla_build],
        zip        => "nsis-3.0b1.zip",
        target_dir => '"C:\Mozilla-Build\"';
    }
}
