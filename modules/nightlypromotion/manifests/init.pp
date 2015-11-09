# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class nightlypromotion {
    include ::config
    include dirs::builds
    include users::builder
    include nightlypromotion::settings
    include packages::mozilla::python27

    $nightlypromotion_user = "${users::builder::username}"

    python::virtualenv {
        "${nightlypromotion::settings::root}":
            python   => "${packages::mozilla::python27::python}",
            require  => [
                Class['packages::mozilla::python27'],
            ],
            user     => "$nightlypromotion_user",
            group    => "${users::builder::group}",
            packages => [
                "mar==1.2",
                "requests==2.8.1",
                "wsgiref==0.1.2",
                "boto==2.27.0",
                "argparse==1.2.1"
            ];
    }

    file {
        "$nightlypromotion::settings::script":
            mode    => '0755',
            owner   => "$nightlypromotion_user",
            source  => 'puppet:///modules/nightlypromotion/nightly_promotion.py';

        "/etc/cron.d/run_nightly_promotion":
            require => File["${nightlypromotion::settings::script}"],
            content => template("nightlypromotion/run_nightlypromotion.cron.erb"),
            owner  => root;
        "$nightlypromotion::settings::aws_authfile":
            mode      => 0600,
            owner     => $nightlypromotion_user,
            show_diff => false,
            content   => template("nightlypromotion/aws-secrets.json.erb");
    }
}
