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
            params         => "-k ${aws_manager::settings::secrets_dir}/aws-secrets.json -c ../configs/watch_pending.cfg -r us-west-2 -r us-east-1 --cached-cert-dir ${aws_manager::settings::secrets_dir}/cached_certs -l ${aws_manager::settings::root}/aws_watch_pending.log";
        "aws_watch_pending_servo":
            script         => "aws_watch_pending.py",
            ensure         => present,
            minute         => '*/5',
            cwd            => "${aws_manager::settings::cloud_tools_dst}/scripts",
            virtualenv_dir => "${aws_manager::settings::root}",
            user           => "${users::buildduty::username}",
            params         => "-k ${aws_manager::settings::secrets_dir}/aws-secrets-servo.json -c ../configs/watch_pending_servo.cfg -r us-east-1 -l ${aws_manager::settings::root}/aws_watch_pending_servo.log";
        "aws_stop_idle.py":
            ensure         => present,
            minute         => '*/10',
            cwd            => "${aws_manager::settings::cloud_tools_dst}/scripts",
            virtualenv_dir => "${aws_manager::settings::root}",
            user           => "${users::buildduty::username}",
            params         => "-c ${aws_manager::settings::secrets_dir}/passwords.json -r us-west-2 -r us-east-1 -j32 -l ${aws_manager::settings::root}/aws_stop_idle.log -t bld-linux64 -t tst-linux64 -t tst-linux32 -t try-linux64";
        "aws_stop_idle_servo":
            script         => "aws_stop_idle.py",
            ensure         => present,
            minute         => '*/10',
            cwd            => "${aws_manager::settings::cloud_tools_dst}/scripts",
            virtualenv_dir => "${aws_manager::settings::root}",
            user           => "${users::buildduty::username}",
            params         => "-c ${aws_manager::settings::secrets_dir}/passwords-servo.json -r us-east-1 -j32 -l ${aws_manager::settings::root}/aws_stop_idle_servo.log -t servo-linux64";
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
            params         => "-r us-west-2 -r us-east-1 -q";
        "spot_sanity_check.py":
            ensure         => present,
            minute         => '*/10',
            cwd            => "${aws_manager::settings::cloud_tools_dst}/scripts",
            virtualenv_dir => "${aws_manager::settings::root}",
            user           => "${users::buildduty::username}",
            params         => "-r us-west-2 -r us-east-1 -q --db ${aws_manager::settings::secrets_dir}/spots.sqlite";
        "instance2ami.py":
            ensure         => absent,  # disabled due to bug 991274
            minute         => '10',
            hour           => '2',
            cwd            => "${aws_manager::settings::cloud_tools_dst}/scripts",
            virtualenv_dir => "${aws_manager::settings::root}",
            user           => "${users::buildduty::username}",
            params         => "-c ../configs/instance2ami.json --keep-last 10 --ssh-key ${users::buildduty::home}/.ssh/aws-ssh-key";
    }

    file {
        "/etc/cron.d/aws-manager-update-hg-clone":
            content => "*/5 * * * * ${users::buildduty::username} cd ${aws_manager::settings::cloud_tools_dst} && ${packages::mozilla::py27_mercurial::mercurial} pull -u\n";
        "/etc/cron.d/aws-manager-delete-old-certs":
            content => "@daily find ${aws_manager::settings::secrets_dir}/cached_certs -type f -mtime +30 -delete\n";
    }
}
