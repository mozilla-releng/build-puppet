# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class pushapk_scriptworker {
    include pushapk_scriptworker::settings
    include dirs::builds
    include packages::mozilla::python35
    include tweaks::swap_on_instance_storage
    include packages::gcc
    include packages::make
    include packages::libffi
    include pushapk_scriptworker::jarsigner_init
    include pushapk_scriptworker::mime_types
    include tweaks::scriptworkerlogrotate

    # If the Python installation changes, we need to rebuild the virtualenv
    # from scratch. Before doing that, we need to stop the running instance.
    exec {
        "stop-for-rebuild-${module_name}":
            command     => "/usr/bin/supervisorctl stop ${module_name}",
            refreshonly => true,
            subscribe   => Class['packages::mozilla::python35'];
    }

    python35::virtualenv {
        $pushapk_scriptworker::settings::root:
            python3         => $packages::mozilla::python35::python3,
            rebuild_trigger => Exec["stop-for-rebuild-${module_name}"],
            require         => Class['packages::mozilla::python35'],
            user            => $pushapk_scriptworker::settings::user,
            group           => $pushapk_scriptworker::settings::group,
            mode            => 700,
            packages        => [
                'PyYAML==3.12',
                'aiohttp==2.3.9',
                'androguard==3.1.0',
                'arrow==0.12.1',
                'asn1crypto==0.24.0',
                'async_timeout==1.4.0',
                'backcall==0.1.0',
                'certifi==2018.1.18',
                'cffi==1.11.4',
                'chardet==3.0.4',
                'colorama==0.3.9',
                'cryptography==2.1.4',
                'decorator==4.3.0',
                'defusedxml==0.5.0',
                'dictdiffer==0.7.0',
                'frozendict==1.2',
                'future==0.16.0',
                'google-api-python-client==1.6.5',
                'httplib2==0.10.3',
                'idna==2.6',
                'ipython==6.3.1',
                'ipython_genutils==0.2.0',
                'jedi==0.12.0',
                'json-e==2.5.0',
                'jsonschema==2.6.0',
                'lxml==4.2.1',
                'mohawk==0.3.4',
                'mozapkpublisher==0.6.0',
                'multidict==4.0.0',
                'networkx==2.1',
                'oauth2client==4.1.2',
                'parso==0.2.0',
                'pexpect==4.3.1',
                'pickleshare==0.7.4',
                'prompt_toolkit==1.0.15',
                'ptyprocess==0.5.2',
                'pushapkscript==0.6.0',
                'pyOpenSSL==17.5.0',
                'pyasn1==0.4.2',
                'pyasn1-modules==0.2.1',
                'pycparser==2.18',
                'Pygments==2.2.0',
                'python-dateutil==2.6.1',
                'python-gnupg==0.4.1',
                'requests==2.18.4',
                'rsa==3.4.2',
                'scriptworker==10.6.0',
                'setuptools==39.0.1',
                'simplegeneric==0.8.1',
                'six==1.10.0',
                'slugid==1.0.7',
                'taskcluster==2.1.3',
                'traitlets==4.3.2',
                'uritemplate==3.0.0',
                'urllib3==1.22',
                'virtualenv==15.1.0',
                'wcwidth==0.1.7',
                'yarl==1.0.0',
            ];
    }

    scriptworker::instance {
        $pushapk_scriptworker::settings::root:
            instance_name            => $module_name,
            basedir                  => $pushapk_scriptworker::settings::root,
            work_dir                 => $pushapk_scriptworker::settings::work_dir,

            task_script              => $pushapk_scriptworker::settings::task_script,

            username                 => $pushapk_scriptworker::settings::user,
            group                    => $pushapk_scriptworker::settings::group,

            taskcluster_client_id    => $pushapk_scriptworker::settings::taskcluster_client_id,
            taskcluster_access_token => $pushapk_scriptworker::settings::taskcluster_access_token,
            worker_group             => $pushapk_scriptworker::settings::worker_group,
            worker_type              => $pushapk_scriptworker::settings::worker_type,

            cot_job_type             => 'pushapk',

            sign_chain_of_trust      => $pushapk_scriptworker::settings::sign_chain_of_trust,
            verify_chain_of_trust    => $pushapk_scriptworker::settings::verify_chain_of_trust,
            verify_cot_signature     => $pushapk_scriptworker::settings::verify_cot_signature,

            verbose_logging          => $pushapk_scriptworker::settings::verbose_logging,
    }

    File {
        ensure      => present,
        mode        => '0600',
        owner       => $pushapk_scriptworker::settings::user,
        group       => $pushapk_scriptworker::settings::group,
        show_diff   => false,
    }

    $google_play_config = $pushapk_scriptworker::settings::google_play_config
    $config_content = $pushapk_scriptworker::settings::script_config_content
    file {
        $pushapk_scriptworker::settings::script_config:
            require => Python35::Virtualenv[$pushapk_scriptworker::settings::root],
            content => inline_template("<%- require 'json' -%><%= JSON.pretty_generate(@config_content) %>");
    }

    case $pushapk_scriptworker_env {
        'dep': {
            file {
                $google_play_config['dep']['certificate_target_location']:
                    content     => $google_play_config['dep']['certificate'];
            }
        }
        'prod': {
            file {
                $google_play_config['aurora']['certificate_target_location']:
                    content     => $google_play_config['aurora']['certificate'];
                $google_play_config['beta']['certificate_target_location']:
                    content     => $google_play_config['beta']['certificate'];
                $google_play_config['release']['certificate_target_location']:
                    content     => $google_play_config['release']['certificate'];
            }
        }
        default: {
            fail("Invalid pushapk_scriptworker_env given: ${pushapk_scriptworker_env}")
        }
    }
}
