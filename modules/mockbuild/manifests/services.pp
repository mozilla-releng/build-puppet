class mockbuild::services {
    include ::config
    include packages::mozilla::supervisor
    include packages::xvfb

    supervisord::supervise {
      "Xvfb":
         command => "Xvfb :2 -screen 0 1280x1024x24",
         user => $::config::builder_username;
    }
}
