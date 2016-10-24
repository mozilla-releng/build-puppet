class beetmover_scriptworker {
    include ::config
    include beetmover_scriptworker::services
    include beetmover_scriptworker::settings
    include dirs::builds
    include packages::mozilla::python35
    include packages::mozilla::git
    include users::builder
    include tweaks::swap_on_instance_storage
    include packages::gcc
    include packages::make
    include packages::libffi

    python35::virtualenv {
        "${beetmover_scriptworker::settings::root}":
            python3  => "${packages::mozilla::python35::python3}",
            require  => Class["packages::mozilla::python35"],
            user     => "${users::builder::username}",
            group    => "${users::builder::group}",
            mode     => 700,
            packages => [
                  "aiohttp==0.22.5",
                  "arrow==0.8.0",
                  "chardet==2.3.0",
                  "defusedxml==0.4.1",
                  "ecdsa==0.13",
                  "frozendict==1.0",
                  "future==0.15.2",
                  "jsonschema==2.5.1",
                  "mohawk==0.3.3",
                  "multidict==1.2.2",
                  "pefile==2016.7.26",
                  "pexpect==4.2.1",
                  "ptyprocess==0.5.1",
                  "pycrypto==2.6.1",
                  "python-dateutil==2.5.3",
                  "python-gnupg==0.3.8",
                  "python-jose==1.2.0",
                  "requests==2.11.1",
                  "scriptworker==0.7.1",
                  "signtool==2.0.3",
                  "six==1.10.0",
                  "slugid==1.0.7",
                  "taskcluster==0.3.4",
                  "virtualenv==15.0.3",
                  "boto3==1.4.1",
                  "botocore==1.4.63",
                  "jmespath==0.9.0",
                  "PyYAML==3.12",
                  "Jinja2==2.8",
                  "beetmoverscript==0.0.1",
                  "MarkupSafe==0.23",
                  "s3transfer==0.1.8",
                  "docutils==0.12",

            ];
    }

    git::repo {
        "beetmoverscript-clone":
            repo    => "${config::beetmover_scriptworker_beetmoverscript_repo_url}",
            dst_dir => "${beetmover_scriptworker::settings::beetmoverscript_dir}",
            user    => "${users::builder::username}",
            require => [
                Class["packages::mozilla::git"],
                Python35::Virtualenv["${beetmover_scriptworker::settings::root}"]
            ];
    }

    file {
        "${beetmover_scriptworker::settings::root}/config.json":
            require     => Python35::Virtualenv["${beetmover_scriptworker::settings::root}"],
            mode        => 600,
            owner       => "${users::builder::username}",
            group       => "${users::builder::group}",
            content     => template("${module_name}/config.json.erb"),
            show_diff   => false;
        "${beetmover_scriptworker::settings::root}/script_config.json":
            require     => Python35::Virtualenv["${beetmover_scriptworker::settings::root}"],
            mode        => 600,
            owner       => "${users::builder::username}",
            group       => "${users::builder::group}",
            content     => template("${module_name}/script_config.json.erb"),
            show_diff   => false;
        '/root/certs.sh':
            ensure => absent;
    }

    service {
        'rpcbind':
            enable => false;
    }
}
