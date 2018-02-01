# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define roller::instance ($port=8000) {

    include ::roller::base
    include ::config

    $environment = $title
    $image_tag = $environment ? {
        'prod'  => $::config::roller_image_tag_prod,
        default => $::config::roller_image_tag_dev,
    }

    $roller_user = 'root'
    $base_dir = "/opt/roller${environment}"

    motd {
        "roller-${environment}":
            content => " - roller ${environment} listening on port ${port}\n",
            order   => 91,
    }

    # In prod, we use the docker image from the docker repo
    # And in dev, we use a local git clone for quick dev/testing
    if $environment == 'dev' {
        git::repo {
            "roller-${environment}":
                repo    => $config::roller_git_repo,
                dst_dir => "${base_dir}",
                user    => $roller_user,
        }
    }

    # Setup a systemd service for this instance
    # eg 'systemctl status docker-compose@rollerdev'
    roller::systemd {
        $environment:
            image_tag => $image_tag;
    }
}

