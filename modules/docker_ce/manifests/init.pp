# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class docker_ce {

    if  $::operatingsystem == 'Ubuntu' and $::operatingsystemrelease == '16.04' {
        include packages::docker_ce

        $docker_compose_version = '1.18.0'

        file {
            # Install docker-compose binary
            "/usr/local/bin/docker-compose-${docker_compose_version}":
                ensure => file,
                mode   => '0755',
                source => "puppet:///repos/bins/docker-compose-${docker_compose_version}";
            # Symlink to docker-compose
            "/usr/local/bin/docker-compose":
                ensure => link,
                target => "/usr/local/bin/docker-compose-${docker_compose_version}";
            # Setup docker-compose systemd service
            '/etc/systemd/system/docker-compose@.service':
                ensure => file,
                mode   => '0644',
                source => 'puppet:///modules/docker_ce/docker-compose.service';
            # Setup docker clean up timer
            '/etc/systemd/system/docker-cleanup.timer':
                ensure => file,
                mode   => '0644',
                source => 'puppet:///modules/docker_ce/docker-cleanup.timer';
            # Setup docker clean up service
            '/etc/systemd/system/docker-cleanup.service':
                ensure => file,
                mode   => '0644',
                source => 'puppet:///modules/docker_ce/docker-cleanup.service';
            # Create directory for docker compose yml configs
            '/etc/docker/compose':
                ensure => directory;
        }
    } else {
        fail("${::operationsystem} ${::operatingsystemrelease} is not supported")
    }

}
