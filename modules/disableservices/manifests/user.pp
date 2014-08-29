# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class disableservices::user($username, $group, $home) {
    # disable services that require a user account
    case $::operatingsystem {
        Darwin : {
            osxutils::defaults {
                'builder-disablescreensaver':
                    domain => "${home}/Library/Preferences/ByHost/com.apple.screensaver.$sp_platform_uuid",
                    key => "idleTime",
                    value => "0";
            }
            file {
                "${home}/Library/Preferences/ByHost":
                    ensure => directory,
                    owner => $username,
                    group => $group,
                    mode => 0700;
                "${home}/Library/Preferences/ByHost/com.apple.screensaver.$sp_platform_uuid.plist":
                    ensure => file,
                    owner => $username,
                    group => $group,
                    mode => 0600;
            }

            # disable Apple's "unsafe files from the internet" warnings
            # http://www.davinian.com/os-x-leopard-are-you-sure-you-want-to-open-it/
            # (as per earlier releng puppet implementations of this).
            file {
                "${home}/Library/Preferences/com.apple.DownloadAssessment.plist":
                    source => "puppet:///modules/${module_name}/com.apple.DownloadAssessment.plist",
                    owner => $username,
                    group => $group,
                    mode => 0600;
            }
            # and to make double-sure, turn off quarantining:
            # http://superuser.com/questions/38658/how-to-suppress-repetition-of-warnings-that-an-application-was-downloaded-from-t
            osxutils::defaults {
                "builder-disable-quarantine":
                    domain => "${home}/Library/Preferences/com.apple.LaunchServices.plist",
                    key => "LSQuarantine",
                    value => "0";
            }
        }
    }
}
