# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class toplevel::server::bsdpy inherits toplevel::server {
    include ::bsdpy
    include ::security

    assert {
      'bsdpy-high-security':
        condition => $::security::high;
    }

    if (has_aspect('dev')) {
        bsdpy::instance {
            'dev':
                server_image_name => 'mozillarelops/bsdpy_server',
                httpd_image_name  => 'mozillarelops/bsdpy_httpd',
                tftpd_image_name  => 'mozillarelops/bsdpy_tftpd',
                image_tag         => 'dev',
                protocol          => 'http',
                iface_name        => 'ens160',
                nbi_root_path     => '/nbi';
        }
    }
    elsif (has_aspect('prod')) {
        bsdpy::instance {
            'prod':
                server_image_name => 'mozillarelops/bsdpy_server',
                httpd_image_name  => 'mozillarelops/bsdpy_httpd',
                tftpd_image_name  => 'mozillarelops/bsdpy_tftpd',
                image_tag         => 'latest',
                protocol          => 'http',
                iface_name        => 'ens160',
                nbi_root_path     => '/nbi';
        }
    } else {
        fail("Environemnt must be specified in \$aspects node-scope variable")
    }


}
