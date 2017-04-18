class buildbot_bridge2::settings {
    include ::config

    $root = $config::buildbot_bridge2_root
    $env_config = $config::buildbot_bridge2_env_config[$buildbot_bridge2_env]
}
