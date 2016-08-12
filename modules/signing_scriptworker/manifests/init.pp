class signing_scriptworker {
    include ::config
    include signing_scriptworker::services
    include signing_scriptworker::settings
    include dirs::builds
    include packages::mozilla::python35
    include users::builder
    include tweaks::swap_on_instance_storage
    include packages::gcc
    include packages::make

    python35::virtualenv {
        "${signing_scriptworker::settings::root}":
            python3   => "${packages::mozilla::python35::python3}",
            require  => Class["packages::mozilla::python35"],
            user     => "${users::builder::username}",
            group    => "${users::builder::group}",
            packages => [
                  "aiohttp==0.22.0a0",
                  "arrow==0.8.0",
                  "chardet==2.3.0",
                  "defusedxml==0.4.1",
                  "ecdsa==0.13",
                  "frozendict==0.6",
                  "future==0.15.2",
                  "jsonschema==2.5.1",
                  "mohawk==0.3.3",
                  "multidict==1.1.0",
                  "pefile==2016.7.26",
                  "pycrypto==2.6.1",
                  "python-dateutil==2.5.3",
                  "python-jose==1.0.0",
                  "requests==2.10.0",
                  "scriptworker==0.3.0",
                  "signingscript==0.2.1",
                  "signtool==2.0.2",
                  "six==1.10.0",
                  "slugid==1.0.7",
                  "taskcluster==0.3.4",
                  "virtualenv==15.0.2",
            ];
    }

    nrpe::custom {
        "signing_scriptworker.cfg":
            content => template("${module_name}/nagios.cfg.erb");
    }

    file {
        "${signing_scriptworker::settings::root}/script_config.json":
            require     => Python35::Virtualenv["${signing_scriptworker::settings::root}"],
            mode        => 600,
            owner       => "${users::builder::username}",
            group       => "${users::builder::group}",
            content     => template("${module_name}/script_config.json.erb"),
            show_diff   => true;
        "${signing_scriptworker::settings::root}/config.json":
            require     => Python35::Virtualenv["${signing_scriptworker::settings::root}"],
            mode        => 600,
            owner       => "${users::builder::username}",
            group       => "${users::builder::group}",
            content     => template("${module_name}/config.json.erb"),
            show_diff   => false;
        "${signing_scriptworker::settings::root}/passwords.json":
            require     => Python35::Virtualenv["${signing_scriptworker::settings::root}"],
            mode        => 600,
            owner       => "${users::builder::username}",
            group       => "${users::builder::group}",
            content     => template("${module_name}/passwords.json.erb"),
            show_diff => false;
    }
}
