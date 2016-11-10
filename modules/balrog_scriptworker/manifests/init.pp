class balrog_scriptworker {
    include ::config
    include balrog_scriptworker::services
    include balrog_scriptworker::settings
    include dirs::builds
    include packages::mozilla::python35
    include packages::mozilla::python27
    include packages::mozilla::git
    include packages::mozilla::py27_mercurial
    include users::builder
    include tweaks::swap_on_instance_storage
    include packages::gcc
    include packages::make
    include packages::libffi

    $env_config = $config::balrog_scriptworker_env_config[$balrogworker_env]

    python35::virtualenv {
        "${balrog_scriptworker::settings::root}":
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
                  "scriptworker==0.7.2",
                  "signtool==2.0.3",
                  "six==1.10.0",
                  "slugid==1.0.7",
                  "taskcluster==0.3.4",
                  "virtualenv==15.0.3",
            ];
    }

    python::virtualenv {
        "${balrog_scriptworker::settings::root}/py27venv":
            python   => "${packages::mozilla::python27::python}",
            require  => Class["packages::mozilla::python27"],
            user     => "${users::builder::username}",
            group    => "${users::builder::group}",
            packages => [
                  "balrogclient==0.0.1",
                  "boto==2.41.0",
                  "cryptography==1.2.3",
                  "enum34==1.1.2",
                  "idna==2.0",
                  "ipaddress==1.0.16",
                  "mar==1.2",
                  "pyasn1==0.1.9",
                  "requests==2.8.1",
                  "six==1.10.0",
            ];
    }

    git::repo {
        "balrogscript":
            repo    => "${balrog_scriptworker::settings::balrogscript_repo}",
            dst_dir => "${balrog_scriptworker::settings::root}/balrogscript",
            user    => "${users::builder::username}",
            require => [
                Class["packages::mozilla::git"],
                Python35::Virtualenv["${balrog_scriptworker::settings::root}"],
            ];
    }

    mercurial::repo {
        "tools":
            hg_repo => "${balrog_scriptworker::settings::tools_repo}",
            dst_dir => "${balrog_scriptworker::settings::root}/balrogscript/tools",
            user    => "${users::builder::username}",
            branch  => "${balrog_scriptworker::settings::tools_branch}",
            require => [
                Class["packages::mozilla::py27_mercurial"],
                Python35::Virtualenv["${balrog_scriptworker::settings::root}"],
                Git::Repo["balrogscript"],
            ];
    }

    file {
        "${balrog_scriptworker::settings::root}/config.json":
            require     => Python35::Virtualenv["${balrog_scriptworker::settings::root}"],
            mode        => 600,
            owner       => "${users::builder::username}",
            group       => "${users::builder::group}",
            content     => template("${module_name}/config.json.erb"),
            show_diff   => false;
        # requirement as part of scriptworker pentest bug 1298199#c23
        '/root/certs.sh':
            ensure => absent;
        "${balrog_scriptworker::settings::root}/balrogscript/keys/dep.pubkey":
            source => "puppet:///modules/balrog_scriptworker/dep.pubkey",
            require     => Git::Repo["balrogscript"],
            owner       => "${users::builder::username}",
            group       => "${users::builder::group}";
        "${balrog_scriptworker::settings::root}/balrogscript/keys/nightly.pubkey":
            source => "puppet:///modules/balrog_scriptworker/nightly.pubkey",
            require     => Git::Repo["balrogscript"],
            owner       => "${users::builder::username}",
            group       => "${users::builder::group}";
        "${balrog_scriptworker::settings::root}/balrogscript/keys/release.pubkey":
            source => "puppet:///modules/balrog_scriptworker/release.pubkey",
            require     => Git::Repo["balrogscript"],
            owner       => "${users::builder::username}",
            group       => "${users::builder::group}";
    }
}
