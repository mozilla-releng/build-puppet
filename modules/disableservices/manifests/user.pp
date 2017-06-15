# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class disableservices::user($username, $group, $home) {
    # disable services that require a user account
    case $::operatingsystem {
        Darwin : {
            osxutils::defaults {
                "${username}-disablescreensaver":
                    domain => "${home}/Library/Preferences/ByHost/com.apple.screensaver.${::sp_platform_uuid}",
                    key    => 'idleTime',
                    value  => '0';
            }
            file {
                "${home}/Library/Preferences/ByHost":
                    ensure => directory,
                    owner  => $username,
                    group  => $group,
                    mode   => '0700';
                "${home}/Library/Preferences/ByHost/com.apple.screensaver.${::sp_platform_uuid}.plist":
                    ensure => file,
                    owner  => $username,
                    group  => $group,
                    mode   => '0600';
            }

            # disable Apple's "unsafe files from the internet" warnings
            # http://www.davinian.com/os-x-leopard-are-you-sure-you-want-to-open-it/
            # (as per earlier releng puppet implementations of this).
            file {
                "${home}/Library/Preferences/com.apple.DownloadAssessment.plist":
                    source => "puppet:///modules/${module_name}/com.apple.DownloadAssessment.plist",
                    owner  => $username,
                    group  => $group,
                    mode   => '0600';
            }
            # and to make double-sure, turn off quarantining:
            # http://superuser.com/questions/38658/how-to-suppress-repetition-of-warnings-that-an-application-was-downloaded-from-t
            osxutils::defaults {
                "${username}-disable-quarantine":
                    domain => "${home}/Library/Preferences/com.apple.LaunchServices.plist",
                    key    => 'LSQuarantine',
                    value  => '0';
            }

            # disable the iCloud setup, and a few others, per
            # http://derflounder.wordpress.com/2013/10/27/disabling-the-icloud-sign-in-pop-up-message-on-lion-and-later/
            if ($::macosx_productversion_major == '10.10') {
                osxutils::defaults {
                    "${username}-disable-icloud":
                        domain => "${home}/Library/Preferences/com.apple.SetupAssistant.plist",
                        key    => 'DidSeeCloudSetup',
                        value  => '1';
                    "${username}-disable-icloud-version":
                        domain => "${home}/Library/Preferences/com.apple.SetupAssistant.plist",
                        key    => 'LastSeenCloudProductVersion',
                        value  => $::macosx_productversion_major;
                    "${username}-disable-gesture-movie":
                        domain => "${home}/Library/Preferences/com.apple.SetupAssistant.plist",
                        key    => 'GestureMovieSeen',
                        value  => 'none';
                }
            }
        }
    }
}
