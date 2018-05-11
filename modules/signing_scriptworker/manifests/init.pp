# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class signing_scriptworker {
    include ::config
    include signing_scriptworker::settings
    include dirs::builds
    include packages::mozilla::python3
    include users::signer
    include tweaks::swap_on_instance_storage
    include packages::gcc
    include packages::make
    include tweaks::scriptworkerlogrotate

    $env_config          = $signing_scriptworker::settings::env_config[$signing_scriptworker_env]

    # because puppet barfs whenever I try to put it in settings.pp
    $verbose_logging     = true
    $build_tools_version = '23.0.3'
    # See value defined in packages::mozilla::android_sdk
    $zipalign_location   = "/tools/android-sdk/build-tools/${build_tools_version}/zipalign"
    $dmg_location        = "${signing_scriptworker::settings::root}/dmg/dmg"
    $hfsplus_location    = "${signing_scriptworker::settings::root}/dmg/hfsplus"

    # If the Python installation changes, we need to rebuild the virtualenv
    # from scratch. Before doing that, we need to stop the running instance.
    exec {
        "stop-for-rebuild-${module_name}":
            command     => "/usr/bin/supervisorctl stop ${module_name}",
            refreshonly => true,
            subscribe   => Class['packages::mozilla::python3'];
    }

    python3::virtualenv {
        $signing_scriptworker::settings::root:
            python3         => $packages::mozilla::python3::python3,
            rebuild_trigger => Exec["stop-for-rebuild-${module_name}"],
            require         => Class['packages::mozilla::python3'],
            user            => $users::signer::username,
            group           => $users::signer::group,
            mode            => '0700',
            packages        => file("signing_scriptworker/requirements.txt");
    }

    scriptworker::instance {
        $signing_scriptworker::settings::root:
            instance_name            => $module_name,
            basedir                  => $signing_scriptworker::settings::root,

            task_script              => $signing_scriptworker::settings::task_script,
            task_script_config       => $signing_scriptworker::settings::task_script_config,

            username                 => $users::signer::username,
            group                    => $users::signer::group,

            taskcluster_client_id    => $env_config['taskcluster_client_id'],
            taskcluster_access_token => $env_config['taskcluster_access_token'],
            worker_group             => $env_config['worker_group'],
            worker_type              => $env_config['worker_type'],
            task_max_timeout         => $signing_scriptworker::settings::task_max_timeout,

            cot_job_type             => 'signing',
            cot_product              => $env_config['cot_product'],

            sign_chain_of_trust      => $env_config["sign_chain_of_trust"],
            verify_chain_of_trust    => $env_config["verify_chain_of_trust"],
            verify_cot_signature     => $env_config["verify_cot_signature"],

            verbose_logging          => $signing_scriptworker::settings::verbose
    }

    file {
        "${signing_scriptworker::settings::root}/script_config.json":
            require   => Python3::Virtualenv[$signing_scriptworker::settings::root],
            mode      => '0600',
            owner     => $users::signer::username,
            group     => $users::signer::group,
            content   => template("${module_name}/script_config.json.erb"),
            show_diff => true;
        "${signing_scriptworker::settings::root}/passwords.json":
            require   => Python3::Virtualenv[$signing_scriptworker::settings::root],
            mode      => '0600',
            owner     => $users::signer::username,
            group     => $users::signer::group,
            content   => template("${module_name}/${env_config['passwords_template']}"),
            show_diff => false;
        "${signing_scriptworker::settings::root}/dmg":
            ensure => directory,
            mode   => '0755',
            owner  => $users::signer::username,
            group  => $users::signer::group;
        $dmg_location:
            mode      => '0755',
            owner     => $users::signer::username,
            group     => $users::signer::group,
            source    => 'puppet:///modules/signing_scriptworker/dmg/dmg',
            show_diff => false;
        $hfsplus_location:
            mode      => '0755',
            owner     => $users::signer::username,
            group     => $users::signer::group,
            source    => 'puppet:///modules/signing_scriptworker/dmg/hfsplus',
            show_diff => false;
        "${signing_scriptworker::settings::root}/KEY":
            require   => Python3::Virtualenv[$signing_scriptworker::settings::root],
            mode      => '0600',
            owner     => $users::signer::username,
            group     => $users::signer::group,
            source    => "puppet:///modules/signing_scriptworker/gpg/${env_config['gpg_keyfile']}",
            show_diff => false;
    }

    packages::mozilla::android_sdk {
      $build_tools_version:
        username          => $users::signer::username,
        group             => $users::signer::group,
        zipalign_location => $zipalign_location;
    }

    class { 'datadog_agent':
        api_key            => $env_config['datadog_api_key'],
        puppet_run_reports => false,
        puppetmaster_user  => puppet,
    }
}
