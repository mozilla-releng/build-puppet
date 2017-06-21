# Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Outlook header API files. Avialable at http://www.microsoft.com/en-us/download/details.aspx?id=12905
# This package is extracted from the the source file. The original file is an archive file wrapped in an exe
# Though the exe accepted cmd line arguments it lead to an extraction that required human interaction
# Hence using the the etracted archive file

class packages::mapi_headers {
    packages::pkgzip {'mapiheader.zip':
        zip        => 'mapiheader.zip',
        target_dir => '"C:\Office 2010 Developer Resources\Outlook 2010 MAPI Headers"';
    }
}
