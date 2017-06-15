# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class dirs::installersource::puppetagain_pub_build_mozilla_org::zips {
    include dirs::installersource::puppetagain_pub_build_mozilla_org
    file {
        "${::env_systemdrive}/installersource/puppetagain.pub.build.mozilla.org/ZIPs":
            ensure => directory,
    }
}
