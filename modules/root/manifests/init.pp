class root {
    include settings

    if ($settings::root_pw_hash == '') {
        failure('No root password hash set')
    }

    user {
        "root":
            password => $settings::root_pw_hash;
    }
}
