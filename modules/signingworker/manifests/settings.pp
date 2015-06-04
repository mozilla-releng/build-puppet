class signingworker::settings {
    include ::config

    $root = $config::signingworker_root
    $tools_dst = "${root}/tools"
}
