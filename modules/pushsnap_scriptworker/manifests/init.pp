# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class pushsnap_scriptworker {
    include pushsnap_scriptworker::settings
    include dirs::builds
    include packages::mozilla::python3
    include users::builder
    include tweaks::swap_on_instance_storage
    include packages::gcc
    include packages::make
    include packages::libffi
    include packages::mozilla::squashfs_tools
    include tweaks::scriptworkerlogrotate
    include tweaks::scriptworkerlogrotate

    # If the Python installation changes, we need to rebuild the virtualenv
    # from scratch. Before doing that, we need to stop the running instance.
    exec {
        "stop-for-rebuild-${module_name}":
            command     => "/usr/bin/supervisorctl stop ${module_name}",
            refreshonly => true,
            subscribe   => Class['packages::mozilla::python3'];
    }

    python3::virtualenv {
        $pushsnap_scriptworker::settings::root:
            python3         => $packages::mozilla::python3::python3,
            rebuild_trigger => Exec["stop-for-rebuild-${module_name}"],
            require         => Class['packages::mozilla::python3'],
            user            => $users::builder::username,
            group           => $users::builder::group,
            mode            => '0700',
            packages        => [
                'aiohttp==2.3.9',
                'arrow==0.12.1',
                'async_timeout==1.4.0',
                'certifi==2018.1.18',
                'cffi==1.11.5',
                'chardet==3.0.4',
                'click==6.7',
                'defusedxml==0.5.0',
                'dictdiffer==0.7.0',
                'frozendict==1.2',
                'idna-ssl==1.0.0',
                'idna==2.6',
                'json-e==2.5.0',
                'jsonschema==2.6.0',
                'mohawk==0.3.4',
                'multidict==4.0.0',
                'pexpect==4.3.1',
                'pluggy==0.6.0',
                'progressbar33==2.4',
                'ptyprocess==0.5.2',
                'pushsnapscript==0.2.0',
                'py==1.5.2',
                'pycparser==2.18',
                'pyelftools==0.24',
                'pymacaroons==0.13.0',
                'PyNaCl==1.2.1',
                'pysha3==1.0.2',
                'python-dateutil==2.6.1',
                'python-debian==0.1.32',
                'python-distutils-extra==2.39',
                'python-gnupg==0.4.1',
                'pyxdg==0.26',
                'PyYAML==3.12',
                'redo==1.6',
                'requests-toolbelt==0.8.0',
                'requests-unixsocket==0.1.5',
                'requests==2.18.4',
                'scriptworker==10.6.2',
                'simplejson==3.13.2',
                'six==1.10.0',
                'slugid==1.0.7',
                'tabulate==0.8.2',
                'taskcluster==2.1.3',
                'urllib3==1.22',
                'virtualenv==15.1.0',
                'yarl==1.0.0',
            ];
    }

    scriptworker::instance {
        $pushsnap_scriptworker::settings::root:
            instance_name            => $module_name,
            basedir                  => $pushsnap_scriptworker::settings::root,

            task_script              => $pushsnap_scriptworker::settings::task_script,
            task_script_config       => $pushsnap_scriptworker::settings::task_script_config,

            username                 => $users::builder::username,
            group                    => $users::builder::group,

            taskcluster_client_id    => $pushsnap_scriptworker::settings::taskcluster_client_id,
            taskcluster_access_token => $pushsnap_scriptworker::settings::taskcluster_access_token,
            worker_group             => $pushsnap_scriptworker::settings::worker_group,
            worker_type              => $pushsnap_scriptworker::settings::worker_type,

            task_max_timeout         => $pushsnap_scriptworker::settings::task_max_timeout,

            cot_job_type             => 'pushsnap',

            sign_chain_of_trust      => $pushsnap_scriptworker::settings::sign_chain_of_trust,
            verify_chain_of_trust    => $pushsnap_scriptworker::settings::verify_chain_of_trust,
            verify_cot_signature     => $pushsnap_scriptworker::settings::verify_cot_signature,

            verbose_logging          => $pushsnap_scriptworker::settings::verbose_logging,
    }

    File {
        ensure      => present,
        mode        => '0600',
        owner       => $pushsnap_scriptworker::settings::user,
        group       => $pushsnap_scriptworker::settings::group,
        show_diff   => false,
    }

    $config_content = $pushsnap_scriptworker::settings::script_config_content
    file {
        $pushsnap_scriptworker::settings::script_config:
            require => Python3::Virtualenv[$pushsnap_scriptworker::settings::root],
            content => inline_template("<%- require 'json' -%><%= JSON.pretty_generate(@config_content) %>");
    }

    $macaroons_config = $pushsnap_scriptworker::settings::macaroons_config
    case $pushsnap_scriptworker_env {
        'dep': {
            # No more files to add
        }
        'prod': {
            file {
                $macaroons_config['beta']['target_location']:
                    content     => $macaroons_config['beta']['content'];
                $macaroons_config['candidate']['target_location']:
                    content     => $macaroons_config['candidate']['content'];
            }
        }
        default: {
            fail("Invalid pushsnap_scriptworker_env given: ${pushsnap_scriptworker_env}")
        }
    }
}
