# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

#Set NTFS options
# Ref: http://technet.microsoft.com/en-us/library/cc938627.aspx

class tweaks::ntfs_options {
    #Set ntfs options
    registry::value { 'DumpType':
        key  => 'HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps',
        data => '1',
    }
    registry::value { 'NtfsDisable8dot3NameCreation':
        key  => 'HKLM\SYSTEM\CurrentControlSet\Control\FileSystem',
        data => '1',
    }
    registry::value { 'NtfsDisableLastAccessUpdate':
        key  => 'HKLM\SYSTEM\CurrentControlSet\Control\FileSystem',
        data => '1',
    }
    registry::value { 'NtfsMemoryUsage':
        key  => 'HKLM\SYSTEM\CurrentControlSet\Control\FileSystem',
        data => '2',
    }
}
