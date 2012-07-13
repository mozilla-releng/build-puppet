class users::global {
    # add some custom stuff to $PATH; some of these may not exist everywhere,
    # but this doesn't hurt.
    case $operatingsystem {
        CentOS : {
            file {
            # see bug 738040 - this can be removed eventually
                "/etc/profile.d/releng-path.sh" :
                    ensure => absent ;
            }
        }
    }

    # put some basic information in /etc/motd
    motd {
        "hostid":
            content => inline_template("This is <%= fqdn %> (<%= ipaddress %>)\n"),
            order => '00';
    }
}
