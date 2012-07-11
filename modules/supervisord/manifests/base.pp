# NB: This is specific to supervisord version 2
class supervisord::base {
    include packages::supervisord

    # The flow here is pretty straightforward
    # Files in /etc/supervisord.conf.d are the root of the dependency tree
    # Changes to any files here trigger Exec["supervisord_make_config"] to run
    # supervisord_make_config creates /tmp/supervisord.conf.tmp
    # /etc/supervisord.conf depends on /tmp/supervisord.conf.tmp, and if it
    # changes, triggers the supervisord service to reload

    file {
        "/etc/supervisord.conf.d/":
            notify => Exec["supervisord_make_config"],
            ensure => directory,
            recurse => true,
            purge => true;

        "/etc/supervisord.conf.d/00header":
            notify => Exec["supervisord_make_config"],
            source => "puppet:///modules/supervisord/supervisord.conf.header";
    }

    exec {
        "supervisord_make_config":
            require => File["/etc/supervisord.conf.d/00header"],
            command => "/bin/cat /etc/supervisord.conf.d/* > /tmp/supervisord.conf.tmp",
            refreshonly => true;
    }

    file {
        "/etc/supervisord.conf":
            require => Exec["supervisord_make_config"],
            source => "/tmp/supervisord.conf.tmp",
            notify => Service["supervisord"];
    }

    service {
        "supervisord":
            require => [
                Class["packages::supervisord"],
                File["/etc/supervisord.conf"],
            ],
            restart => "/usr/bin/supervisorctl reload",
            enable => true,
            ensure => running;
    }
}
