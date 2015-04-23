class buildbot_bridge::settings {
    include ::config

    $root = $config::buildbot_bridge_root
}
