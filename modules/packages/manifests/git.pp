# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::git{
    
    file {
        "C:/installersource/puppetagain.pub.build.mozilla.org/EXEs/Git-1.9.2-preview20140411.exe":
            ensure  => file,
            source  => "puppet:///repos/EXEs/Git-1.9.2-preview20140411.exe",
            require => Class["dirs::installersource::puppetagain_pub_build_mozilla_org::exes"];
    }
    exec {
         "Git-1.9.2-preview20140411.exe":
            command => "C:\\installersource\\puppetagain.pub.build.mozilla.org\\EXEs\\Git-1.9.2-preview20140411.exe /VERYSILENT /DIR=C:\mozilla-build\Git",
            creates => "C:\\mozilla-build\\git\\unins000.exe",
            require => File["C:/installersource/puppetagain.pub.build.mozilla.org/EXEs/Git-1.9.2-preview20140411.exe"],
    }
}
