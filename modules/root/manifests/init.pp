class root {
    include secrets

    if ($secrets::root_pw_hash == '') {
        fail('No root password hash set')
    }

    user {
        "root":
            password => $secrets::root_pw_hash;
    }
}
