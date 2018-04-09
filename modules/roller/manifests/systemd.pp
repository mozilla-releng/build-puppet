# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define roller::systemd ($image_tag){

    include docker_ce

    $environment = $title
    $taskcluster_client_id = secret('roller_taskcluster_client_id')
    $taskcluster_access_token = secret('roller_taskcluster_access_token')

    $moonshot_ipmi_user = secret('roller_moonshot_ipmi_user')
    $moonshot_ipmi_password = secret('roller_moonshot_ipmi_password')

    $snmp_community_string = secret('roller_snmp_community_string')

    $django_secret_key = secret('roller_django_secret_key')

    $bugzilla_api_key = secret('roller_bugzilla_api_key')

    $ssl_key = secret('roller_ssl_key')
    $ssl_cert = secret('roller_ssl_cert')

    file {
        # Do not put '-' or '_' in directory name.  docker-compose will strip it
        # when creating containers and this breaks the systemd use of %i
        "/etc/docker/compose/roller${environment}":
            ensure => directory,
            mode   => 0640;
        "/etc/docker/compose/roller${environment}/ssl.key":
            ensure  => file,
            mode    => 0640,
            content => $ssl_key;
        "/etc/docker/compose/roller${environment}/ssl.crt":
            ensure  => file,
            content => $ssl_cert;
        "/etc/docker/compose/roller${environment}/worker_config.json":
            ensure  => file,
            content => template("roller/${environment}/worker_config.json.erb");
        "/etc/docker/compose/roller${environment}/docker-compose.yml":
            ensure  => file,
            mode    => 0640,
            content => template("roller/${environment}/docker-compose.yml.erb");
        "/etc/docker/compose/roller${environment}/nginx.conf":
            ensure  => file,
            content => template("roller/${environment}/nginx.conf.erb");
        "/etc/docker/compose/roller${environment}/.env":
            ensure  => file,
            mode    => 0640,
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
