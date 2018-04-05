# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class signing_scriptworker {
    include ::config
    include signing_scriptworker::settings
    include dirs::builds
    include packages::mozilla::python35
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

    python35::virtualenv {
        $signing_scriptworker::settings::root:
            python3  => $packages::mozilla::python35::python3,
            require  => Class['packages::mozilla::python35'],
            user     => $users::signer::username,
            group    => $users::signer::group,
            mode     => '0700',
            packages => [
                  'PyYAML==3.12',
                  'aiohttp==2.3.9',
                  'arrow==0.12.1',
                  'async-timeout==1.4.0',
                  'certifi==2018.1.18',
                  'chardet==3.0.4',
                  'datadog==0.17.0',
                  'decorator==4.2.1',
                  'defusedxml==0.5.0',
                  'dictdiffer==0.7.0',
                  'ecdsa==0.13',
                  'frozendict==1.2',
                  'future==0.16.0',
                  'json-e==2.5.0',
                  'jsonschema==2.6.0',
                  'idna==2.5',
                  'mohawk==0.3.4',
                  'multidict==4.0.0',
                  'pexpect==4.3.1',
                  'ptyprocess==0.5.2',
                  'pycryptodome==3.3.1',
                  'python-dateutil==2.6.1',
                  'python-gnupg==0.4.1',
                  'python-jose==2.0.0',
                  'requests==2.18.1',
                  'scriptworker==10.2.0',
                  'signingscript==6.0.1',
                  'signtool==3.1.6',
                  'simplejson==3.13.2',
                  'six==1.10.0',
                  'slugid==1.0.7',
                  'taskcluster==2.1.3',
                  'urllib3==1.21.1',
                  'virtualenv==15.1.0',
                  'yarl==1.0.0',
            ];
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
            require   => Python35::Virtualenv[$signing_scriptworker::settings::root],
            mode      => '0600',
            owner     => $users::signer::username,
            group     => $users::signer::group,
            content   => template("${module_name}/script_config.json.erb"),
            show_diff => true;
        "${signing_scriptworker::settings::root}/passwords.json":
            require   => Python35::Virtualenv[$signing_scriptworker::settings::root],
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
            require   => Python35::Virtualenv[$signing_scriptworker::settings::root],
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
