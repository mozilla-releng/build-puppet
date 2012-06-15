class smarthost::setup {

   include config

   file { "/etc/postfix/main.cf":
        owner => "postfix",
        group => "postfix",
        mode => 0644,
        ensure => present,
        content => template("smarthost/main.cf.erb"),
        require => Class["smarthost::install"],
        notify => Class["smarthost::daemon"],
   }

}
