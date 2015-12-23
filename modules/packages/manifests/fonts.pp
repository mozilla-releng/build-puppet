# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::fonts {
    case $::operatingsystem {
        Ubuntu: {
            package {
                [ "fonts-kacst-one", "fonts-kacst", "fonts-liberation",
                  "ttf-indic-fonts-core", "ttf-kannada-fonts", "ttf-dejavu",
                  "ttf-oriya-fonts", "ttf-punjabi-fonts", "ttf-arphic-uming",
                  "ttf-paktype", "fonts-stix", "fonts-unfonts-core",
                  "fonts-unfonts-extra", "fonts-vlgothic", "ttf-sazanami-mincho"]:
                    ensure => latest;
            }
        }
        Darwin: {
            # Nothing to do
        }
        default: {
            fail("Don't know how to install fonts on $::operatingsystem")
        }
    }
}
