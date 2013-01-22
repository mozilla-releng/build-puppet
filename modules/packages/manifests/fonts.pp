class packages::fonts {
    case $::operatingsystem {
        Ubuntu: {
            package {
                ["fonts-kacst-one", "fonts-kacst", "fonts-liberation",
                 "ttf-indic-fonts-core", "ttf-kannada-fonts", "ttf-dejavu",
                 "ttf-oriya-fonts", "ttf-punjabi-fonts", "ttf-arphic-uming",
                 "ttf-paktype", "fonts-stix", "fonts-unfonts-core",
                 "fonts-unfonts-extra"]:
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
