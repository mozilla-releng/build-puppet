class users::root::setup($home, $username, $group) {
    anchor {
        'users::root::setup::begin': ;
        'users::root::setup::end': ;
    }

    ##
    # install a pip.conf for the root user

    Anchor['users::root::setup::begin'] ->
    python::user_pip_conf {
        $username:
            homedir => $home,
            group => $group;
    } -> Anchor['users::root::setup::end']
}
