# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class shipit_scriptworker {
    include shipit_scriptworker::settings
    include dirs::builds
    include packages::mozilla::python3
    include tweaks::swap_on_instance_storage
    include packages::gcc
    include packages::make
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
        $shipit_scriptworker::settings::root:
            python3         => $packages::mozilla::python3::python3,
            rebuild_trigger => Exec["stop-for-rebuild-${module_name}"],
            require         => Class['packages::mozilla::python3'],
            user            => $shipit_scriptworker::settings::user,
            group           => $shipit_scriptworker::settings::group,
            mode            => 700,
            packages        => [
                'PyYAML==3.12',
                'aiohttp==2.3.9',
                'arrow==0.12.1',
                'async_timeout==1.4.0',
                'certifi==2018.1.18',
                'chardet==3.0.4',
                'defusedxml==0.5.0',
                'dictdiffer==0.7.0',
                'frozendict==1.2',
                'idna==2.6',
                'json-e==2.5.0',
                'jsonschema==2.6.0',
                'mohawk==0.3.4',
                'multidict==4.0.0',
                'pexpect==4.3.1',
                'ptyprocess==0.5.2',
                'python-dateutil==2.6.1',
                'python-gnupg==0.4.1',
                'redo==1.6',
                'requests==2.18.4',
                'scriptworker==10.6.2',
                'shipitapi==0.1.0',
                'shipitscript==1.0.0',
                'six==1.10.0',
                'slugid==1.0.7',
                'taskcluster==2.1.3',
                'urllib3==1.22',
                'virtualenv==15.1.0',
                'yarl==1.0.0',
            ];
    }

    scriptworker::instance {
        $shipit_scriptworker::settings::root:
            instance_name            => $module_name,
            basedir                  => $shipit_scriptworker::settings::root,
            work_dir                 => $shipit_scriptworker::settings::work_dir,

            task_script              => $shipit_scriptworker::settings::task_script,

            username                 => $shipit_scriptworker::settings::user,
            group                    => $shipit_scriptworker::settings::group,

            taskcluster_client_id    => $shipit_scriptworker::settings::taskcluster_client_id,
            taskcluster_access_token => $shipit_scriptworker::settings::taskcluster_access_token,
            worker_group             => $shipit_scriptworker::settings::worker_group,
            worker_type              => $shipit_scriptworker::settings::worker_type,

            cot_job_type             => 'shipit',

            sign_chain_of_trust      => $shipit_scriptworker::settings::sign_chain_of_trust,
            verify_chain_of_trust    => $shipit_scriptworker::settings::verify_chain_of_trust,
            verify_cot_signature     => $shipit_scriptworker::settings::verify_cot_signature,

            verbose_logging          => $shipit_scriptworker::settings::verbose_logging,
    }

    File {
        ensure      => present,
        mode        => '0600',
        owner       => $shipit_scriptworker::settings::user,
        group       => $shipit_scriptworker::settings::group,
        show_diff   => false,
    }

    $config_content = $shipit_scriptworker::settings::script_config_content
    file {
        $shipit_scriptworker::settings::script_config:
            require => Python3::Virtualenv[$shipit_scriptworker::settings::root],
            content => inline_template("<%- require 'json' -%><%= JSON.pretty_generate(@config_content) %>");
    }
}
