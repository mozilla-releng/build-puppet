# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class fw::apps {
    $app_proto_port = { 'ssh'             => { proto => 'tcp', port  => '22' },
                        'vnc'             => { proto => 'tcp', port  => '5900' },
                        'nrpe'            => { proto => 'tcp', port  => '5666' },
                        'http'            => { proto => 'tcp', port  => '80' },
                        'https'           => { proto => 'tcp', port  => '443' },
                        'puppet'          => { proto => 'tcp', port  => '8140' },
                        'bacula'          => { proto => 'tcp', port  => '9102' },
                        'dep_signing'     => { proto => 'tcp', port  => '9110' },
                        'rel_signing'     => { proto => 'tcp', port  => '9120' },
                        'nightly_signing' => { proto => 'tcp', port  => '9100' },
                        }
}
