class signing_scriptworker {
    include ::config
    include signing_scriptworker::services
    include signing_scriptworker::settings
    include dirs::builds
    include packages::mozilla::python35
    include packages::mozilla::git
    include users::signer
    include tweaks::swap_on_instance_storage
    include packages::gcc
    include packages::make

    python35::virtualenv {
        "${signing_scriptworker::settings::root}":
            python3  => "${packages::mozilla::python35::python3}",
            require  => Class["packages::mozilla::python35"],
            user     => "${users::signer::username}",
            group    => "${users::signer::group}",
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
                  "scriptworker==0.9.0",
                  "signingscript==0.6.0",
                  "signtool==2.0.3",
                  "six==1.10.0",
                  "slugid==1.0.7",
                  "taskcluster==0.3.4",
                  "virtualenv==15.0.3",
            ];
    }

    git::repo {
        "scriptworker-${signing_scriptworker::settings::git_key_repo_dir}":
            repo    => "${config::signing_scriptworker_gpg_repo_url}",
            dst_dir => $signing_scriptworker::settings::git_key_repo_dir,
            user    => "${users::signer::username}",
            require => Python35::Virtualenv["${signing_scriptworker::settings::root}"];
    }

    nrpe::custom {
        "signing_scriptworker.cfg":
            content => template("${module_name}/nagios.cfg.erb");
    }

    file {
        "${signing_scriptworker::settings::root}/scriptworker.json":
            require     => Python35::Virtualenv["${signing_scriptworker::settings::root}"],
            mode        => 600,
            owner       => "${users::signer::username}",
            group       => "${users::signer::group}",
            content     => template("${module_name}/scriptworker.json.erb"),
            show_diff   => false;
        "${signing_scriptworker::settings::root}/cot_config.json":
            require     => Python35::Virtualenv["${signing_scriptworker::settings::root}"],
            mode        => 600,
            owner       => "${users::signer::username}",
            group       => "${users::signer::group}",
            content     => template("${module_name}/cot_config.json.erb"),
            show_diff   => true;
        "${signing_scriptworker::settings::root}/script_config.json":
            require     => Python35::Virtualenv["${signing_scriptworker::settings::root}"],
            mode        => 600,
            owner       => "${users::signer::username}",
            group       => "${users::signer::group}",
            content     => template("${module_name}/script_config.json.erb"),
            show_diff   => true;
        "${signing_scriptworker::settings::root}/passwords.json":
            require     => Python35::Virtualenv["${signing_scriptworker::settings::root}"],
            mode        => 600,
            owner       => "${users::signer::username}",
            group       => "${users::signer::group}",
            content     => template("${module_name}/passwords.json.erb"),
            show_diff => false;
        '/root/certs.sh':
            ensure => absent;
        "${signing_scriptworker::settings::root}/config.json":
            ensure => absent;
        "/home/${users::signer::username}/.gnupg":
            ensure      => directory,
            mode        => 700,
            owner       => "${users::signer::username}",
            group       => "${users::signer::group}";
        "/home/${users::signer::username}/pubkey":
            mode        => 644,
            content     => $config::signing_scriptworker_gpg_public_keys[$fqdn],
            owner       => "${users::signer::username}",
            group       => "${users::signer::group}";
        "/home/${users::signer::username}/privkey":
            mode        => 600,
            content     => $config::signing_scriptworker_gpg_private_keys[$fqdn],
            owner       => "${users::signer::username}",
            group       => "${users::signer::group}",
            show_diff   => false;
        "${signing_scriptworker::settings::git_pubkey_dir}":
            ensure      => directory,
            mode        => 700,
            owner       => "${users::signer::username}",
            group       => "${users::signer::group}",
            source      => 'puppet:///modules/signing_scriptworker/git_pubkeys',
            recurse     => true,
            recurselimit => 1,
            purge       => true;
        "/etc/cron.d/scriptworker":
            content     => template("signing_scriptworker/scriptworker.cron.erb");
        "${signing_scriptworker::settings::root}/.git-pubkey-dir-checksum":
            owner       => "${users::signer::username}",
            group       => "${users::signer::group}",
            notify  => Exec['create_gpg_homedirs'];
    }

    exec {
        'create_gpg_homedirs':
            require => [Python35::Virtualenv["${signing_scriptworker::settings::root}"],
                        Git::Repo["scriptworker-${signing_scriptworker::settings::git_key_repo_dir}"],
                        File["${signing_scriptworker::settings::root}/scriptworker.json"],
                        File["${signing_scriptworker::settings::root}/cot_config.json"]],
            command => "${signing_scriptworker::settings::root}/bin/create_initial_gpg_homedirs ${signing_scriptworker::settings::root}/scriptworker.json ${signing_scriptworker::settings::root}/cot_config.json",
            subscribe => File["${signing_scriptworker::settings::git_pubkey_dir}"],
            user    => "${users::signer::username}";
        "${signing_scriptworker::settings::root}/.git-pubkey-dir-checksum":
            path    => "/usr/local/bin/:/bin:/usr/sbin",
            user    => "${users::signer::username}",
            command => "find ${signing_scriptworker::settings::git_pubkey_dir} -type f | xargs md5sum | sort > ${signing_scriptworker::settings::root}/.git-pubkey-dir-checksum";
    }
}
