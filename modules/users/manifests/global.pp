class users::global {
    anchor {
        'users::global::begin': ;
        'users::global::end': ;
    }

    # put some basic information in /etc/motd
    Anchor['users::global::begin'] ->
    motd {
        "hostid":
            content => inline_template("This is <%= fqdn %> (<%= ipaddress %>)\n"),
            order => '00';
    } -> Anchor['users::global::end']
}
