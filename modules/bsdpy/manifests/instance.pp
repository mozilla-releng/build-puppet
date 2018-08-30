# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define bsdpy::instance (
    $server_image_name,
    $httpd_image_name,
    $tftpd_image_name,
    $image_tag     = 'latest',
    $protocol      = 'http',
    $iface_name    = 'eth0',
    $nbi_root_path = '/nbi')
    {

    include docker_ce
    include bsdpy

    $environment = $title

    $motd_msg = "- bsdpy ${environment} server\n\
-- server image:  ${server_image_name}:${image_tag}\n\
-- httpd image:   ${httpd_image_name}:${image_tag}\n\
-- tftpd image:   ${tftpd_image_name}:${image_tag}\n\
-- nbi protocol:  ${protocol}\n\
-- nbi root path: ${nbi_root_path}\n"

    motd {
        "bsdpy-${environment}":
            content => $motd_msg,
            order   => 91,
    }

    file {
        # Do not put '-' or '_' in directory name.  docker-compose will strip it
        # when creating containers and this breaks the systemd use of %i
        "/etc/docker/compose/bsdpy":
            ensure => directory,
            mode   => 0640;
        "/etc/docker/compose/bsdpy/docker-compose.yml":
            ensure  => file,
            mode    => 0640,
            content => template("bsdpy/docker-compose.yml.erb");
    }

    service {
        "docker-compose@bsdpy":
            ensure    => running,
            provider  => 'systemd',
            enable    => true,
            subscribe => File["/etc/docker/compose/bsdpy/docker-compose.yml"],
    }
}
