# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class pushapk_scriptworker::mime_types {

    case $::operatingsystem {
        # This file is used by google-api-python-client to make sure it's pushing an APK. It relies on
        # https://docs.python.org/3/library/mimetypes.html which needs this file, no matter what disto
        # we're on. Without it, google-api-python-client refuses to handle files.
        CentOS: {
            file { '/etc/mime.types':
                mode    => '0644',
                content => 'application/vnd.android.package-archive     apk',
            }
        }
        default: {
            fail("cannot install on ${::operatingsystem}")
        }
    }
}
