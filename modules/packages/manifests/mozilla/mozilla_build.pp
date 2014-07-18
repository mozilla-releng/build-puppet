# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

#Mozilla build package source: https://wiki.mozilla.org/MozillaBuild
#MozillaBuildSetup-Latest.zip is manually repackaged using 7 zip
#It is repackaged because the original exe cannot be silently installed and when extracted charecters in the top level directories are not recognized by Windows

class packages::mozilla::mozilla_build {
    include packages::7z920
        exec { "mozilla_build":
            creates => 'C:\mozilla-build\VERSION',
            require => Class["packages::7z920"],
            command => '"C:\Program Files (x86)\7-Zip\7z.exe" x C:\InstallerSource\puppetagain.pub.build.mozilla.org\ZIPs\MozillaBuildSetup-Latest.zip -oC:\mozilla-build -y'
    }
}  
