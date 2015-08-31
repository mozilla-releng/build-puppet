class buildbot_bridge::settings {
    include ::config

    $root = $config::buildbot_bridge_root
    $env_config = $config::buildbot_bridge_env_config[$buildbot_bridge_env]
}
