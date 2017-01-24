define scriptworker::nagios(
  $basedir,
) {

  nrpe::custom {
      "scriptworker.cfg":
          content => template("scriptworker/nagios.cfg.erb");
  }

  File {
      require     => Python35::Virtualenv[$basedir],
      mode        => 750,
  }

  file {
    "${nrpe::base::plugins_dir}/nagios_file_age_check.py":
        source      => "puppet:///modules/scriptworker/nagios_file_age_check.py";
    "${nrpe::base::plugins_dir}/nagios_pending_tasks.py":
        content     => template("scriptworker/nagios_pending_tasks.py.erb");
  }
}
