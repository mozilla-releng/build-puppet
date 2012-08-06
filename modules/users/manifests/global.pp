class users::global {
    # put some basic information in /etc/motd
    motd {
        "hostid":
            content => inline_template("This is <%= fqdn %> (<%= ipaddress %>)\n"),
            order => '00';
    }
}
