# NB: This is specific to supervisord version 2
class supervisord::base {
    include packages::mozilla::supervisor

    file {
        "/etc/supervisord.conf":
            source => "puppet:///modules/supervisord/supervisord.conf";

        "/etc/supervisord.conf.d/":
            notify => Service["supervisord"],
            ensure => directory,
            recurse => true,
            purge => true;

    }

    service {
        "supervisord":
            require => [
                Class["packages::mozilla::supervisor"],
                File["/etc/supervisord.conf"],
            ],
            restart => "/usr/bin/supervisorctl reload",
            enable => true,
            ensure => running;
    }
}
