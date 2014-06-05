# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class aws_manager {
    include aws_manager::install
    include aws_manager::secrets
    include aws_manager::cron
    include nrpe::check::check_stop_idle
}
