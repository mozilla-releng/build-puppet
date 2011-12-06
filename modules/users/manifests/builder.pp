# Set up the builder user - this is 'cltbld' on firefox systems, but flexible
# enough to be anything

class users::builder {
    include secrets
    include settings

    if ($secrets::builder_pw_hash == '') {
        fail('No builder password hash set')
    }

    if ($settings::builder_username == '') {
        fail('No builder username set')
    }

    user {
        "$settings::builder_username":
            password => $secrets::builder_pw_hash,
            shell => "/bin/bash",
            managehome => true,
            comment => "Builder";
    }
}

