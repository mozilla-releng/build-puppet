class signingworker {
    include ::config
    include signingworker::services
    include signingworker::settings
    include dirs::builds
    include packages::mozilla::python27
    include users::builder

    python::virtualenv {
        "${signingworker::settings::root}":
            python   => "${packages::mozilla::python27::python}",
            require  => Class["packages::mozilla::python27"],
            user     => "${users::builder::username}",
            group    => "${users::builder::group}",
            packages => [
                 "PyHawk-with-a-single-extra-commit==0.1.5",
                 "amqp==1.4.6",
                 "anyjson==0.3.3",
                 "argparse==1.2.1",
                 "arrow==0.5.4",
                 "configman==1.2.13",
                 "configobj==5.0.6",
                 "jsonschema==2.4.0",
                 "kombu==3.0.26",
                 "python-dateutil==2.4.2",
                 "redo==1.4.1",
                 "requests==2.4.3",
                 "sh==1.11",
                 "six==1.9.0",
                 "taskcluster==0.0.16",
                 "wsgiref==0.1.2",
                 "signingworker==0.2"
           ];
    }

    nrpe::custom {
        "signingworker.cfg":
            content => template("${module_name}/nagios.cfg.erb");
    }

    mercurial::repo {
        "signingworker-tools":
            require => Python::Virtualenv["${signingworker::settings::root}"],
            hg_repo => "${config::signingworker_tools_repo}",
            dst_dir => "${signingworker::settings::tools_dst}",
            user    => "${users::builder::username}",
            branch  => "${config::signingworker_tools_branch}",
    }

    file {
        "${signingworker::settings::root}/config.json":
            require     => Python::Virtualenv["${signingworker::settings::root}"],
            mode        => 600,
            owner       => "${users::builder::username}",
            group       => "${users::builder::group}",
            content     => template("${module_name}/config.json.erb"),
            show_diff   => false;
        "${signingworker::settings::root}/passwords.json":
            require     => Python::Virtualenv["${signingworker::settings::root}"],
            mode        => 600,
            owner       => "${users::builder::username}",
            group       => "${users::builder::group}",
            content     => template("${module_name}/passwords.json.erb"),
            show_diff => false;
    }
}
