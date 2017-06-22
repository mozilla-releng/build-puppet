# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define scriptworker::supervisord(
  $instance_name,
  $basedir,
  $script_worker_config,
  $task_script_config,
  $username,
  $restart_process_when_changed,
) {
  supervisord::supervise {
      $instance_name:
          command      => "${basedir}/bin/scriptworker ${script_worker_config}",
          user         => $username,
          require      => $restart_process_when_changed,
          extra_config => template("${module_name}/supervisor_config.erb");
  }

  exec {
      "restart-${instance_name}":
          command     => "/usr/bin/supervisorctl restart ${instance_name}",
          refreshonly => true,
          subscribe   => $restart_process_when_changed;
  }
}
