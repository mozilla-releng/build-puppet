# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Ref. http://technet.microsoft.com/en-us/library/dd734783%28v=ws.10%29.aspx regarding netsh command.

class fw::windows_settings {
    # Ping allowance is based on icmp settings
    # Allow ping
    shared::execonce { 'AllowPing':
        command =>'"C:\Windows\System32\netsh.exe" firewall set icmpsetting 8'
    }

    # The following allows remote desktop group access through the firewall.
    # Allow rdp
    shared::execonce { 'AllowRDP':
        command =>'"C:\Windows\System32\netsh.exe" advfirewall firewall set rule group="Remote Desktop" new enable=yes'
    }
}
