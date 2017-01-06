# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Handle installing Python virtualenvs containing Python packages.
# https://wiki.mozilla.org/ReleaseEngineering/Puppet/Modules/python
define scriptworker::instance(
    $basedir, $task_script_executable, $task_script, $task_script_config,
    $username, $group, $worker_group, $worker_type, $cot_job_type,
    $taskcluster_client_id, $taskcluster_access_token,
    $task_max_timeout=1200, $artifact_expiration_hours=336,
    $artifact_upload_timeout=1200, $verbose_logging=false,
    $sign_chain_of_trust=false, $verify_chain_of_trust=false,
    $verify_cot_signature=false
) {
    include scriptworker::instance::settings
    include packages::mozilla::git
    include packages::mozilla::supervisor

    # some constants
    $git_key_repo_dir = "${basedir}/gpg_key_repo/"
    $git_pubkey_dir = "${basedir}/git_pubkeys/"

    # This git repo has the various worker pubkeys
    git::repo {
        "scriptworker-${git_key_repo_dir}":
            repo    => "${scriptworker::instance::settings::git_key_repo_url}",
            dst_dir => $git_key_repo_dir,
            user    => "${username}",
            require => Python35::Virtualenv["${basedir}"];
    }

    nrpe::custom {
        "scriptworker.cfg":
            content => template("scriptworker/nagios.cfg.erb");
    }

    file {
        # scriptworker config
        "${basedir}/scriptworker.yaml":
            require     => Python35::Virtualenv["${basedir}"],
            mode        => 600,
            owner       => "${username}",
            group       => "${group}",
            content     => template("scriptworker/scriptworker.yaml.erb"),
            show_diff   => false;
        # cleanup per bug 1298199
        '/root/certs.sh':
            ensure => absent;
        # $username's gpg homedir: for git commit signature verification
        "/home/${username}/.gnupg":
            ensure      => directory,
            mode        => 700,
            owner       => "${username}",
            group       => "${group}";
        # these are the pubkeys that can sign git commits
        "${git_pubkey_dir}":
            ensure      => directory,
            mode        => 700,
            owner       => "${username}",
            group       => "${group}",
            source      => 'puppet:///modules/scriptworker/git_pubkeys',
            recurse     => true,
            recurselimit => 1,
            purge       => true,
            require     => Python35::Virtualenv["${basedir}"];
        # cron jobs to poll git + rebuild gpg homedirs
        "/etc/cron.d/scriptworker":
            content     => template("scriptworker/scriptworker.cron.erb");
        # Notify rebuild_gpg_homedirs if the pubkey dir changes
        "${basedir}/.git-pubkey-dir-checksum":
            owner       => "${username}",
            group       => "${group}",
            notify  => Exec['rebuild_gpg_homedirs'];
        "/home/${username}/pubkey":
            mode        => 644,
            content     => $config::scriptworker_gpg_public_keys[$fqdn],
            owner       => "${username}",
            group       => "${group}";
        "/home/${username}/privkey":
            mode        => 600,
            content     => $config::scriptworker_gpg_private_keys[$fqdn],
            owner       => "${username}",
            group       => "${group}",
            show_diff   => false;
        "${nrpe::base::plugins_dir}/nagios_file_age_check.py":
            require     => Python35::Virtualenv["${basedir}"],
            mode        => 750,
            owner       => "${username}",
            group       => "${group}",
            source      => "puppet:///modules/scriptworker/nagios_file_age_check.py",
            show_diff => false;
        "${nrpe::base::plugins_dir}/nagios_pending_tasks.py":
            require     => Python35::Virtualenv["${basedir}"],
            mode        => 750,
            owner       => "${username}",
            group       => "${group}",
            content     => template("scriptworker/nagios_pending_tasks.py.erb"),
            show_diff => false;
    }

    exec {
        # create gpg homedirs on change
        'rebuild_gpg_homedirs':
            require => [Python35::Virtualenv["${basedir}"],
                        Git::Repo["scriptworker-${git_key_repo_dir}"],
                        File["${basedir}/scriptworker.yaml"]],
            command => "${basedir}/bin/rebuild_gpg_homedirs ${basedir}/scriptworker.yaml",
            subscribe => File["${git_pubkey_dir}"],
            user    => "${username}";
        # Create checksum file of git pubkeys
        "${basedir}/.git-pubkey-dir-checksum":
            require => File["${git_pubkey_dir}"],
            path    => "/usr/local/bin/:/bin:/usr/sbin:/usr/bin",
            user    => "${username}",
            command => "find ${git_pubkey_dir} -type f | xargs md5sum | sort > ${basedir}/.git-pubkey-dir-checksum";
    }
}
