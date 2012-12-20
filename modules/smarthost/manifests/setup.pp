class smarthost::setup {
    include ::config

    file {
        "/etc/postfix/main.cf":
            owner => "postfix",
            group => "postfix",
            mode => 0644,
            ensure => present,
            content => template("smarthost/main.cf.erb"),
            require => Class["smarthost::install"],
            notify => Class["smarthost::daemon"];
        "/etc/aliases":
            source => "puppet:///modules/smarthost/aliases",
            require => Class['smarthost::install'],
            notify => Exec['newaliases'];
    }

    exec {
        'newaliases':
            command => "/usr/bin/newaliases",
            refreshonly => true;
    }
}
