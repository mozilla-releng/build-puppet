# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::mozilla::google_chrome {
    anchor {
        'packages::mozilla::google_chrome::begin': ;
        'packages::mozilla::google_chrome::end': ;
    }

    case $::operatingsystem {
        Ubuntu: {
            realize(Packages::Aptrepo['google_chrome'])
            case $::operatingsystemrelease {
                16.04: {
                    Anchor['packages::mozilla::google_chrome::begin'] ->
                    file {
                        '/etc/apt/sources.list.d/google-chrome.list':
                            source => 'puppet:///modules/packages/google-chrome.list',
                    }
                    schedule { 'update-chrome-schedule':
                        period => weekly,
                        repeat => 1,
                    }
                    exec { 'update-chrome-action':
                        schedule => 'update-chrome-schedule',
                        command  => '/usr/bin/apt-get update -o Dir::Etc::sourcelist="sources.list.d/google-chrome.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"',
                    }
                    package {
                        'google-chrome-stable':
                            ensure => latest;
                    } -> Anchor['packages::mozilla::google_chrome::end']
                }
                default: {
                    fail("Unrecognized Ubuntu version ${::operatingsystemrelease}")
                }
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
