# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define roller::systemd ($image_tag){

    include docker_ce

    $environment = $title

    file {
        # Do not put '-' or '_' in directory name.  docker-compose will strip it
        # when creating containers and this breaks the systemd use of %i
        "/etc/docker/compose/roller${environment}":
            ensure => directory;
        "/etc/docker/compose/roller${environment}/docker-compose.yml":
            ensure  => file,
            content => template("roller/${environment}/docker-compose.yml.erb");
        "/etc/docker/compose/roller${environment}/.env":
            ensure  => file,
            content => template("roller/${environment}/env.erb");
    }

    # Only start at boot and ensure running if it is a prodution instance
    if $environment == 'prod' {
        service {
            "docker-compose@roller${environment}":
                ensure    => running,
                provider  => 'systemd',
                enable    => true,
                subscribe => File["/etc/docker/compose/roller${environment}/docker-compose.yml", "/etc/docker/compose/roller${environment}/.env"],
        }
    } else {
        service {
            "docker-compose@roller${environment}":
                provider  => 'systemd',
                enable    => false,
                subscribe => File["/etc/docker/compose/roller${environment}/docker-compose.yml", "/etc/docker/compose/roller${environment}/.env"],
        }
    }
}
