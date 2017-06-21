# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::gstreamer {
    case $::operatingsystem {
        Ubuntu: {
            case $::operatingsystemrelease {
                12.04: {
                    package {
                        [ 'gstreamer0.10-ffmpeg', 'gstreamer0.10-plugins-base',
                          'gstreamer0.10-plugins-good', 'gstreamer0.10-plugins-ugly',
                        # plugins-bad contains a libfaad-based AAC decoder that will make
                        # tests succeed - see bug 912854
                          'gstreamer0.10-plugins-bad']:
                            ensure => latest;
                    }
                }
                16.04: {
                    package {
                      # In ubuntu 16.04, gstreamer0.10-ffmpeg was replaced with gstreamer1.0-libav
                        'gstreamer1.0-libav':
                            ensure => '1.8.0-1';
                        ['gstreamer1.0-plugins-ugly','gstreamer1.0-plugins-base']:
                            ensure => '1.8.3-1ubuntu0.1';
                        'gstreamer1.0-plugins-bad':
                            ensure => '1.8.3-1ubuntu0.2';
                        'gstreamer1.0-plugins-good':
                            ensure => '1.8.3-1ubuntu0.3';
                    }
                }
                default: {
                    fail("Ubuntu ${::operatingsystemrelease} is not supported")
                }
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
