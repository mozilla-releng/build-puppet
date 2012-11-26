class users::root::setup($home, $username, $group) {
    anchor {
        'users::root::setup::begin': ;
        'users::root::setup::end': ;
    }
    include ::config

    ##
    # install a pip.conf for the root user

    Anchor['users::root::setup::begin'] ->
    python::user_pip_conf {
        $username:
            homedir => $home,
            group => $group;
    } -> Anchor['users::root::setup::end']

    ##
    # set up SSH configuration

    Anchor['users::root::setup::begin'] ->
    ssh::userconfig {
        $username:
            home => $home,
            group => $group,
            authorized_keys => [
                $::config::global_authorized_keys,
                # get the node-scoped value, if any
                $extra_root_keys ? {
                    undef => [ ],
                    default => $extra_root_keys
                }];
    } -> Anchor['users::root::setup::end']

}
