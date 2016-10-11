class signing_scriptworker::settings {
    include ::config

    $root = $config::signing_scriptworker_root
    $git_key_repo_dir = "${root}/gpg_key_repo/"
    $git_pubkey_dir = "${root}/git_pubkeys/"
}
