# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define bmm::script {
    file {
        "/opt/bmm/www/scripts/${title}":
            ensure => file,
            content => template("bmm/${title}.erb");
    }
}
