# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mapi_headers {
    #Outlook header API files. Avialable at http://www.microsoft.com/en-us/download/details.aspx?id=12905
    package { "Outlook2010MAPIHeaders.EXE":
        ensure          => installed,
        source          => 'C:\InstallerSource\puppetagain.pub.build.mozilla.org\msis\Outlook2010MAPIHeaders.EXE',
        install_options => ['/quiet'],
    }
 }

