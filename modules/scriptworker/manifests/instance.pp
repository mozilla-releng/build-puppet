# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Handle installing Python virtualenvs containing Python packages.
# https://wiki.mozilla.org/ReleaseEngineering/Puppet/Modules/python
define scriptworker::instance(
    $instance_name,
    $basedir,
    $task_script,
    $username,
    $group,

    $taskcluster_client_id,
    $taskcluster_access_token,
    $worker_group,
    $worker_type,
    $cot_job_type,
    $cot_product                  = 'firefox',

    $work_dir                     = "${basedir}/work",
    $script_worker_config         = "${basedir}/scriptworker.yaml",
    $task_script_executable       = "${basedir}/bin/python",
    $task_script_config           = "${basedir}/script_config.json",

    $worker_id                    = $hostname,
    $task_max_timeout             = 3600,
    $artifact_upload_timeout      = 1200,

    $sign_chain_of_trust          = true,
    $verify_chain_of_trust        = true,
    $verify_cot_signature         = true,

    $verbose_logging              = false,

    $restart_process_when_changed = undef,
) {
    include scriptworker::instance::settings
    include packages::mozilla::git
    include packages::mozilla::supervisor
    include tweaks::scriptworkerlogrotate

    # These constants need to be filled in $script_worker_config, even though Chain of Trust is not enabled.
    $git_key_repo_dir = "${basedir}/gpg_key_repo/"
    $git_pubkey_dir   = "${basedir}/git_pubkeys/"

    validate_taskcluster_identifier($worker_group)
    validate_taskcluster_identifier($worker_type)
    # Hostname may be longer than 22 characters. Getting an error is painful especially in dev environments.
    # That's why we strip worker_id if the default value (aka hostname) is used.
    if $worker_id == $hostname {
      $sanitized_worker_id = regsubst($hostname, '^.*(.{22})$', '\1')
      if $sanitized_worker_id != $worker_id {
        notify {
          "Hostname '${hostname}' too long! worker_id has been stripped to '${sanitized_worker_id}'":
            loglevel => warning,
        }
      }
    } else {
      validate_taskcluster_identifier($worker_id)
      $sanitized_worker_id = $worker_id
    }

    # XXX Workaround to have arrays as default values
    if $restart_process_when_changed == undef {
      $_restart_process_when_changed = [Python3::Virtualenv[$basedir], File[$script_worker_config]]
    } else {
      $_restart_process_when_changed = $restart_process_when_changed
    }


    File {
        ensure      => present,
        mode        => '0600',
        owner       => $username,
        group       => $group,
        show_diff   => false,
    }

    file {
        $script_worker_config:
            require => Python3::Virtualenv[$basedir],
            content => template('scriptworker/scriptworker.yaml.erb');
        # cleanup per bug 1298199
        '/root/certs.sh':
            ensure => absent;
    }

    scriptworker::nagios { $instance_name:
        username => $username,
    }

    scriptworker::supervisord { $instance_name:
        instance_name                => $instance_name,
        basedir                      => $basedir,
        script_worker_config         => $script_worker_config,
        task_script_config           => $task_script_config,
        username                     => $username,
        restart_process_when_changed => $_restart_process_when_changed,
    }

    # Activate Chain Of Trust
    if $sign_chain_of_trust or $verify_cot_signature {
      scriptworker::chain_of_trust { $instance_name:
        basedir          => $basedir,

        git_key_repo_dir => $git_key_repo_dir,
        git_key_repo_url => $scriptworker::instance::settings::git_key_repo_url,
        git_pubkey_dir   => $git_pubkey_dir,

        pubkey           => $config::scriptworker_gpg_public_keys[$fqdn],
        privkey          => $config::scriptworker_gpg_private_keys[$fqdn],

        username         => $username,
      }
    }
}
