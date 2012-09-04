class mockbuild::services {
    include ::config
    include packages::mozilla::supervisor
    include packages::xvfb

    supervisord::supervise {
      "Xvfb":
         command => "Xvfb :2",
         user => $::config::builder_username;
    }
}
