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
