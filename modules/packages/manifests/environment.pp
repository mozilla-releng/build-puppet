# This class is used to configure the system wide environment.

class packages::environment ($path_additions) {

    file {
        "/etc/profile.d/mozilla-environment.sh":
            ensure => file,
            mode => 444,
            owner => root,
            group => root,
            content => template("packages/mozilla-environment.erb");
    }
}
