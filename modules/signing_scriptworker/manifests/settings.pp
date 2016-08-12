class signing_scriptworker::settings {
    include ::config

    $root = $config::signing_scriptworker_root
    $signingscript_dst = "${root}/signingscript"
}
