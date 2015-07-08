# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# These are machines that connect to our mobile testers and act as build slaves
# However these do not reboot frequently, and typically handle multiple
# buildbot instances at once.

class toplevel::server::aws_manager inherits toplevel::server {
    include ::security
    assert {
      'aws-manager-high-security':
        condition => $::security::high;
    }
    include nrpe::check::check_free_aws_ips
    include ::aws_manager
}

