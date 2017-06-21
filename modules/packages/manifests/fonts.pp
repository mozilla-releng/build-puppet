# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::fonts {
    case $::operatingsystem {
        Ubuntu: {
            case $::operatingsystemrelease {
                12.04: {
                    package {
                        [ 'fonts-kacst-one', 'fonts-kacst', 'fonts-liberation',
                        'ttf-indic-fonts-core', 'ttf-kannada-fonts', 'ttf-dejavu',
                        'ttf-oriya-fonts', 'ttf-punjabi-fonts', 'ttf-arphic-uming',
                        'ttf-paktype', 'fonts-stix', 'fonts-unfonts-core',
                        'fonts-unfonts-extra', 'fonts-vlgothic', 'ttf-sazanami-mincho']:
                            ensure => latest;
                    }
                }
                16.04: {
                    package {
                        'fonts-kacst-one':
                            ensure => '5.0+svn11846-7';
                        'fonts-kacst':
                            ensure => '2.01+mry-12';
                        'fonts-liberation':
                            ensure => '1.07.4-1';
                        'fonts-indic':
                            ensure => '2:1.2';
                        'fonts-knda':
                        # ttf-kannada-fonts was replaced by the fonts-knda 
                            ensure => '2:1.2';
                        'fonts-dejavu':
                            ensure => '2.35-1';
                        'fonts-orya':
                        # ttf-oriya-fonts was replaced by fonts-orya
                            ensure => '2:1.2';
                        'fonts-guru':
                        # ttf-punjabi-fonts was replaced by 
                            ensure => '2:1.2';
                        'fonts-arphic-uming':
                        # ttf-arphic-uming was replaced by fonts-arphic-uming
                            ensure => '0.2.20080216.2-7ubuntu2';
                        'fonts-paktype':
                        # ttf-paktype was replaced by fonts-paktype
                            ensure => '0.0svn20121225-2';
                        'fonts-stix':
                            ensure => '1.1.1-4';
                        'fonts-unfonts-core':
                            ensure => '1.0.3.is.1.0.2-080608-10ubuntu1';
                        'fonts-unfonts-extra':
                            ensure => '1.0.3.is.1.0.2-080608-4ubuntu2';
                        'fonts-vlgothic':
                            ensure => '20141206-1ubuntu1';
                        'fonts-ipafont-mincho':
                        # ttf-sazanami-mincho is Japanese free Mincho TrueType font to alternate with the ttf-kochi alternative font family.
                        # Both this package and its alternative kochi font are legacy and deprecated. 
                        # You are recommended to transition to other modern font packages such as "fonts-ipafont-mincho". 
                            ensure => '00303-13ubuntu1';
                    }
                }
                default: {
                    fail("Unrecognized Ubuntu version ${::operatingsystemrelease}")
                }
            }
        }
        Darwin: {
            # Nothing to do
        }
        default: {
            fail("Don't know how to install fonts on ${::operatingsystem}")
        }
    }
}
