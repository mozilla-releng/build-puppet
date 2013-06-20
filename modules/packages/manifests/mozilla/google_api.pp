# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mozilla::google_api {
    include dirs::builds
    file {
        "/builds/gapi.data":
            content => secret("google_api_key"),
            mode    => 0644;
    }
}
