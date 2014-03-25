# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class aws_manager::cron {
    include aws_manager::settings
    include users::buildduty
    include packages::mozilla::py27_mercurial

    aws_manager::crontask {
        "aws_watch_pending.py":
            ensure         => present,
            minute        => '*/5',
            cwd            => "${aws_manager::settings::cloud_tools_dst}/scripts",
            virtualenv_dir => "${aws_manager::settings::root}",
            user           => "${users::buildduty::username}",
            params         => "-k ${aws_manager::settings::secrets_dir}/aws-secrets.json -c ../configs/watch_pending.cfg -r us-west-2 -r us-east-1 -r us-west-1";
        "aws_stop_idle.py":
            ensure         => present,
            minute         => '*/10',
            cwd            => "${aws_manager::settings::cloud_tools_dst}/scripts",
            virtualenv_dir => "${aws_manager::settings::root}",
            user           => "${users::buildduty::username}",
            params         => "-c ${aws_manager::settings::secrets_dir}/passwords.json -r us-west-2 -r us-east-1 -r us-west-1 -j32 -l ${aws_manager::settings::root}/aws_stop_idle.log -t bld-linux64 -t tst-linux64 -t tst-linux32";
        "aws_sanity_checker.py":
            ensure         => present,
            minute        => '0,30',
            cwd            => "${aws_manager::settings::cloud_tools_dst}/scripts",
            virtualenv_dir => "${aws_manager::settings::root}",
            user           => "${users::buildduty::username}",
            params         => "-r us-west-2 -r us-east-1 -r us-west-1";
        "tag_spot_instances.py":
            ensure         => present,
            minute         => '*/2',
            cwd            => "${aws_manager::settings::cloud_tools_dst}/scripts",
            virtualenv_dir => "${aws_manager::settings::root}",
            user           => "${users::buildduty::username}",
            params         => "-r us-west-2 -r us-east-1 -r us-west-1 -q";
        "spot_sanity_check.py":
            ensure         => present,
            minute         => '*/10',
            cwd            => "${aws_manager::settings::cloud_tools_dst}/scripts",
            virtualenv_dir => "${aws_manager::settings::root}",
            user           => "${users::buildduty::username}",
            params         => "-r us-west-2 -r us-east-1 -r us-west-1 -q --db ${aws_manager::settings::secrets_dir}/spots.sqlite";
        "instance2ami.py":
            ensure         => present,
            minute         => '10',
            hour           => '2',
            cwd            => "${aws_manager::settings::cloud_tools_dst}/scripts",
            virtualenv_dir => "${aws_manager::settings::root}",
            user           => "${users::buildduty::username}",
            params         => "-c ../configs/instance2ami.json --keep-last 10 --ssh-key ${users::buildduty::home}/.ssh/aws-ssh-key";
    }

    file {
        "/etc/cron.d/aws-manager-update-hg-clone":
            content => "*/5 * * * * ${users::buildduty::username} cd ${aws_manager::settings::cloud_tools_dst} && ${packages::mozilla::py27_mercurial::mercurial} pull -u";
        "/etc/cron.d/aws-manager-delete-old-certs":
            content => "@daily find ${aws_manager::settings::secrets_dir}/cached_certs -type f -mtime +30 -delete";
    }
}
