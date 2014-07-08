# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::7z920 {
    # Source comes from http://www.7-zip.org/
    #This is required to install Mozilla build package
    package { "7z920.msi":
        ensure          => installed,
        source          => 'C:\InstallerSource\puppetagain.pub.build.mozilla.org\msis\7z920.msi',
        install_options => ['/quiet'],
    }
 }

